pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract CycloneDEX {

    using SafeMath for uint256;

    enum Side {
        BUY,
        SELL
    }

    struct Token {
        bytes32 ticker;
        address tokenAddress;
    }

    struct Order {
        uint256 id;
        address trader;
        Side side;
        bytes32 ticker;
        uint256 amount;
        uint256 filled;
        uint256 price;
        uint256 date;
    }

    mapping(bytes32 => Token) public tokens;
    bytes32[] public tokenList;
    mapping(address => mapping(bytes32 => uint256)) public traderBalances;
    mapping(bytes32 => mapping(uint256 => Order[])) public orderBook;
    address public admin;
    uint256 public nextOrderId;
    uint256 public nextTradeId;
    bytes32 constant DAI = bytes32('DAI');

    event NewTrade(
        uint256 tradeId,
        uint256 orderId,
        bytes32 indexed ticker,
        address indexed trader1,
        address indexed trader2,
        uint256 amount,
        uint256 price,
        uint256 date
    );

    constructor() {
        admin = msg.sender;
    }

    function getOrders(bytes32 ticker, Side side) external view returns(Order[] memory) {
        return orderBook[ticker][uint(side)];
    }

    function getTokens() external view returns(Token[] memory) {
        Token[] memory _tokens = new Token[](tokenList.length);
        for (uint i = 0; i < tokenList.length; i++) {
            _tokens[i] = Token(
                tokens[tokenList[i]].ticker,
                tokens[tokenList[i]].tokenAddress
            );
        }
        return _tokens;
    }

    function addToken(bytes32 ticker, address tokenAddress) onlyAdmin() external {
        tokens[ticker] = Token(ticker, tokenAddress);
        tokenList.push(ticker);
    }

    function deposit(uint256 amount, bytes32 ticker) tokenExists(ticker) external {
        IERC20(tokens[ticker].tokenAddress).transferFrom(
            msg.sender, address(this), amount
        );
        traderBalances[msg.sender][ticker] = traderBalances[msg.sender][ticker].add(amount);
    }
    
    function withdraw(uint256 amount, bytes32 ticker) external {
        require(
            traderBalances[msg.sender][ticker] >= amount,
            'Your balance is insufficient'
        );
    }

    function createLimitOrder(bytes32 ticker, uint256 amount, uint256 price, Side side) tokenExists(ticker) tokenIsNotDai(ticker) external {
        if(side == Side.SELL) {
            require(
                traderBalances[msg.sender][ticker] >= amount,
                'Your balance is insufficient'
            );
        } else {
            require(
                traderBalances[msg.sender][DAI] >= amount.mul(price),
                'Your balance of DAI is insufficient'
            );
        }
        Order[] storage orders = orderBook[ticker][uint(side)];
        orders.push(Order(
            nextOrderId,
            msg.sender,
            side,
            ticker,
            amount,
            0,
            price,
            block.timestamp
        ));

        uint i = orders.length > 0 ? orders.length - 1 : 0;
        while(i > 0) {
            if(side == Side.BUY && orders[i - 1].price > orders[i].price) {
                break;
            }
            if(side == Side.SELL && orders[i - 1].price < orders[i].price) { //Bubble sort algorithm to arrange prices in descending order
                break;
            }
            Order memory order = orders[i - 1];
            orders[i - 1] = orders[i - 1];
            orders[i] = order;
            i--;
        }
        nextOrderId++;
        
    }

    function createMarketOrder(bytes32 ticker, uint256 amount, Side side) tokenExists(ticker) tokenIsNotDai(ticker) external {
        if(side == Side.SELL) {
            require(
                traderBalances[msg.sender][ticker] >= amount,
                'Your balance is insufficient'
            );
        }
        Order[] storage orders = orderBook[ticker][uint(side == Side.BUY ? Side.SELL : Side.BUY)];
    }

    modifier tokenIsNotDai(bytes32 ticker) {
        require(ticker != DAI, 'cannot trade DAI');
        _;
    }

    modifier tokenExists(bytes32 ticker) {
        require(
            tokens[ticker].tokenAddress != address(0),
            'this token does not exist'
        );
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, 'only admin');
        _;
    }

}