pragma solidity ^0.8.0;

import "@studydefi/money-legos/dydx/contracts/DydxFlashloanBase.sol";
import "@studydefi/money-legos/dydx/contracts/ICallee.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import './Compound.sol';

contract YieldFarm is ICallee, DydxFlashloanBase, Compound {
    enum Direction { Deposit, Withdraw }
    struct Operation {
        address token;
        address compoundToken;
        Direction direction;
        uint256 amountProvided;
        uint256 amountBorrowed;
    }

    address public owner;

    constructor(address _comptroller) Compound(_comptroller) public {
        owner = msg.sender;
    }

    function openPosition(
        address _solo,
        address _token,
        address _compoundToken,
        uint256 _amountProvided,
        uint256 _amountBorrowed
    ) external {
        require(msg.sender == owner, 'only owner');
        IERC20(_token).transferFrom(msg.sender, address(this), _amountProvided);
        _initiateFlashLoan(_solo, _token, _compoundToken, Direction.Deposit, _amountProvided - 2,_amountBorrowed);
    }

    function closedPosition(
        addres _solo,
        address _token,
        address _compoundToken
    ) external {
        require(msg.sender == owner, 'only owner');
        IERC20(_token).transferFrom(msg.sender, address(this, 2));
        claimComp();
        uint256 borrowBalance = getBorrowBalance(_cToken);
        _initiateFlashLoan(_solo, _token, _compoundToken, Direction.Withdraw, 0, borrowBalance);

        address compoundAddress = getCompoundAddress();
        IERC20 compound = IERC20(compoundAddress);
        uint256 compoundBalance = compound.balanceOf(address(this));

        IERC20 token = IERC20(_token);
        uint256 tokenBalance = token.balanceOf(address(this));
        compound.transfer(msg.sender, compoundBalance);

        IERC20 token = IERC20(_token);
        uint256 tokenBalance = token.balanceOf(address(this));
        token.transfer(msg.sender, tokenBalance);
    }

    function callFunction(
        address sender,
        Account.Info memory account,
        bytes memory data
    ) public {
        Operation memory operation = abi.decode(data, (Operation));

        if(operation.direction = Direction.Deposit) {
            supply(operation.compoundToken, operation.amountProvided + operation.amountBorrowed);
            enterMarket(operation.compoundToken);
            borrow(operation.compoundToken, operation.amountBorrowed);
        } else {
            repayBorrowedAmount(operation.compoundToken, opertion.amountBorrowed);
            uint256 compoundTokenBalance = getCompoundTokenBalance(operation.compoundToken);
            redeem(operation.compoundToken, compoundTokenBalance);
        }
    }

    function _initiateFlashloan(
        address _solo,
        address _token,
        address _compoundToken,
        Direction _direction,
        uint256 _amountProvided,
        uint256 _amountBorrowed
    ) internal {
        ISolomargin solo = ISoloMargin(_solo);

        uint256 marketId = _getMarketIdFromTokenAddress(_solo, _token);

        uint256 repayAmount = _getRepaymentAmountInternal(Borrowed);
        IERC20(_token).approve(_solo, repayAmount);

        Actions.ActionArgs[] memory operations = new Actions.ActionArgs[](3);
        operations[1] = getCallAction(
            abi.encode(Operation({
                token: _token,
                compoundToken: _compoundToken,
                direction: _direction,
                amountProvided: _amountProvided,
                amountBorrowed: _amountBorrowed
            }))
        );
        operations[2] = _getDepositAction(marketId, repayAmount);

        Account.Info[] memory accountInfos = new Account.Info[](1);
        accountInfos[0] = _getAccountInfo();

        solo.operate(accountInfos, operations);
    }
}