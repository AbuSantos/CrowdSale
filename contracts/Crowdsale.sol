// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "./SafeMath.sol";

// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/interfaces/IERC20.sol";
// import "./ERC20.sol";
// import "https://github.com/ConsenSysMesh/openzeppelin-solidity/blob/master/contracts/token/ERC20/ERC20.sol";
// import "https://github.com/ConsenSysMesh/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol";

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    function burn(uint256 _value) external returns (bool success);
}

contract Crowdsale {
    using SafeMath for uint256;

    // The token being sold
    IERC20 public token;

    // Address where funds are collected
    address public wallet;

    // How many token units a buyer gets per wei
    uint256 public rate;

    // Amount of wei raised
    uint256 public weiRaised;

    event Received(address sender, uint amount);
    /**
     * Event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );

    /**
     * @param _rate Number of token units a buyer gets per wei
     * @param _wallet Address where collected funds will be forwarded to
     * @param _token Address of the token being sold
     */

    constructor(uint256 _rate, address _wallet, address _token) {
        require(_rate > 0);
        require(_wallet != address(0));
        require(_token != address(0));

        rate = _rate;
        wallet = _wallet;
        token = IERC20(_token);
    }

    /**
   * @dev fallback function ***DO NOT OVERRIDE***
  //  */
    fallback() external payable {
        buyTokens(msg.sender);
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    /**
     * @dev low level token purchase ***DO NOT OVERRIDE***
     * @param _beneficiary Address performing the token purchase
     */
    function buyTokens(address _beneficiary) public payable {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(_beneficiary, weiAmount);

        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);

        // update state
        weiRaised = weiRaised.add(weiAmount);
        _processPurchase(_beneficiary, tokens);

        emit TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);

        _updatePurchasingState(_beneficiary, weiAmount);
        _forwardFunds(msg.value);
        _postValidatePurchase(_beneficiary, weiAmount);
    }

    /**
     * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use super to concatenate validations.
     * @param _beneficiary Address performing the token purchase
     * @param _weiAmount Value in wei involved in the purchase
     */
    function _preValidatePurchase(
        address _beneficiary,
        uint256 _weiAmount
    ) internal pure {
        require(_beneficiary != address(0));
        require(_weiAmount != 0);
    }

    /**
     * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
     * @param _beneficiary Address performing the token purchase
     * @param _weiAmount Value in wei involved in the purchase
     */
    function _postValidatePurchase(
        address _beneficiary,
        uint256 _weiAmount
    ) internal {
        // optional override
    }

    // 0x4815A8Ba613a3eB21A920739dE4cA7C439c7e1b1
    // 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
    /**
     * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
     * @param _beneficiary Address performing the token purchase
     * @param _tokenAmount Number of tokens to be emitted
     */
    function _deliverTokens(
        address _beneficiary,
        uint256 _tokenAmount
    ) internal {
        token.transfer(_beneficiary, _tokenAmount);
    }

    /**
     * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
     * @param _beneficiary Address receiving the tokens
     * @param _tokenAmount Number of tokens to be purchased
     */
    function _processPurchase(
        address _beneficiary,
        uint256 _tokenAmount
    ) internal {
        _deliverTokens(_beneficiary, _tokenAmount);
    }

    /**
     * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
     * @param _beneficiary Address receiving the tokens
     * @param _weiAmount Value in wei involved in the purchase
     */
    function _updatePurchasingState(
        address _beneficiary,
        uint256 _weiAmount
    ) internal {
        // optional override
    }

    /**
     * @dev Override to extend the way in which ether is converted to tokens.
     * @param _weiAmount Value in wei to be converted into tokens
     * @return Number of tokens that can be purchased with the specified _weiAmount
     */
    function _getTokenAmount(
        uint256 _weiAmount
    ) internal view returns (uint256) {
        return _weiAmount.mul(rate);
    }

    /**
     * @dev Determines how ETH is stored/forwarded on purchases.
     */
    function _forwardFunds(uint256 _value) internal {
        // bool sent =  wallet.transfer(address(wallet),msg.value);
        address payable receiver = payable(wallet);
        receiver.transfer(_value);
        // require(sent, "Transaction failed");
    }

    function getWallet() public view returns (uint) {
        return address(wallet).balance;
    }

    function getTokenBalance() public view returns (uint) {
        return address(token).balance;
    }
}