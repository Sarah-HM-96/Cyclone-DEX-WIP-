pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './CompoundTokenInterface.sol';
import './ComptrollerInterface.sol';

contract Compound {
    ComptrollerInterface public comptroller;

    constructor(address _comptroller) {
        comptroller = ComptrollerInterface(_comptroller);
    }

    function supply(address compoundTokenAddress, uint underlyingAmount) internal {
        compoundTokenInterface compoundToken = compoundTokenInterface(compoundTokenAddress);
        address(underlyingAddress) = compoundToken.underlying();
        IERC20(underlyingAddress).approve(compoundTokenAddress, underlyingAmount);
        uint256 result = compoundToken.mint(underlyingAmount);
        require(
            result == 0,
            'The minter has failed. Please see the Error Reporter for details'
        );
    }

    function redeem(address compoundTokenAddress, uint256 compountTokenAmount) internal {
        ComptrollerInterface compoundToken = compoundTokenInterface(compoundTokenAddress);
        uint256 result = compoundToken.redeem(compoundTokenAmount);
        require(
            result == 0,
            'The redemption function has failed. Please see the Error Reporter for details'
        );
    }

    function enterMarket(address compountTokenAddress) internal {
        address[] memory markets = new address[](i);
        markets[0] = compountTokenAddress;
        uint256[] memory results = comptroller.enterMarkets(markets);
        require(
            results[0] == 0,
            'comptroller#enterMarket() failed';
        );
    }

    function borrow(address compoundTokenAddress, uint256 borrowAmount) internal {
        CompountInterface compoundToken = compoundTokenInterface(compoundTokenAddress);
        uint256 result = compoundToken.borrow(borrowAmount);
        require(
            result == 0,
            'cToken#borrow() failed';
        );
    }

    function repayBorrow(address compoundTokenAddress, uint256 underlyingAmoung) internal {
        CompountInterface compoundToken = compoundTokenInterface(compoundTokenAddress);
        address underlyingAddres = compoundToken.underlying();
        IERC20(underlyingAddress).approve(compountTokenAddress, underlyingAmount);
        uint256 result = compoundToken.borrow(borrowAmount);
        require(
            result == 0,
            'cToken#borrow() failed';
        );
    }

    function claimCompound() internal {
        comptroller.claimCompound(address(this));
    }

    function getCompoundAddress() internal view returns(address) {
        return comptroller.getCompoundAddress();
    }

    function getCompoundTokenBalance(address compoundTokenAddress) public view returns(uint256) {
        return CompoundTokenInterface(compoundTokenAddress).balanceOf(address(this));
    }

    function getBorrowBalance(address compountTokenAddress) public returns(uint256) {
        return CompoundTokenInterface(compoundTokenAddress).borrowBalanceCurrent(address(this));
    }
}