// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "./SafeMath.sol";
import "./IERC20.sol";


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

    mapping(address => uint256) public contributions;
    mapping(address => uint256) public caps;
    uint public cap;

    uint public openingTime;
    uint public closingTime;

    mapping (address => bool) whiteList;

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

    constructor(uint256 _rate, address _wallet, address _token/*, uint _cap uint _openingTime, uint _closingTime*/) {
        require(_rate > 0);
        require(_wallet != address(0));
        require(_token != address(0));
        // require(cap>0);
        // require(_openingTime >= block.timestamp);
        // require(_closingTime >= _openingTime);

        rate = _rate;
        wallet = _wallet;
        token = IERC20(_token);
        // cap = _cap;

        // openingTime = _openingTime;
        // closingTime = _closingTime;
    }


    // modifier onlyWhileOpen{
    //     require( block.timestamp >= openingTime  && block.timestamp <= closingTime);
    //     _;
    // }

    modifier isWhitelisted(address _investor) {
         require(whiteList[_investor]);
    _;
    }

    /**
   * @dev fallback function ***DO NOT OVERRIDE***
  //  */
    // fallback() external payable {
    //     buyTokens(msg.sender);
    // }

    receive() external payable {
        buyTokens(msg.sender);
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
        require(weiRaised.add(weiAmount)<=cap);
        _processPurchase(_beneficiary, tokens);

        emit TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);

        _updatePurchasingState(_beneficiary, weiAmount);
        _forwardFunds();
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
    function _forwardFunds() internal {
        address payable receiver = payable(wallet);
        // bool sent =  wallet.transfer(address(wallet),msg.value);
        receiver.transfer(msg.value);
        // require(sent, "Transaction failed");
    }

    function getWalletBalance() public view returns (uint) {
        return address(wallet).balance;
    }

    function getTokenBalance() public view returns (uint) {
        return address(token).balance;
    }

 
    function getUserCap(address _beneficiary) external view returns (uint256){
        return caps[_beneficiary];
    }

    function getUserContributions(address _beneficiary) external view returns (uint256){
        return contributions[_beneficiary];
    }

    function addToWhiteList(address _investor) external{
        whiteList[_investor]=true;
    }

    function removeFromWhiteList(address _investor) external{
        whiteList[_investor]=false;
    }

    function setGroupWhiteList (address[] memory _investors)external /*onlyOwner*/{
        for (uint i=0; i < _investors.length ; i++) 
        {
           whiteList[ _investors[i]]=true;
        }
    }

    function setCap (address _beneficiary, uint _cap ) external {
        caps[_beneficiary]=_cap;
    }

    function setGroupCap (address[] memory _beneficiaries, uint256 _cap)external /*onlyOwner*/{
        for (uint i=0; i < _beneficiaries.length ; i++) 
        {
           caps[ _beneficiaries[i]] = _cap;
        }
    }

    function capReached() public view returns (bool){
       return weiRaised>=cap;
    }

    // function hasClosed() external view returns (bool) {
    //      return block.timestamp > closingTime;
    // }

}
