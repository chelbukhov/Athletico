

pragma solidity ^0.4.24;


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address _who) external view returns (uint256);

  function allowance(address _owner, address _spender) external view returns (uint256);

  function transfer(address _to, uint256 _value) external returns (bool);

  function approve(address _spender, uint256 _value) external returns (bool);

  function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b,"Math error");

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0,"Math error"); // Solidity only automatically asserts when dividing by 0
        uint256 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a,"Math error");
        uint256 c = _a - _b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a,"Math error");

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0,"Math error");
        return a % b;
    }
}


/**
 * @title Standard ERC20 token
 * @dev Implementation of the basic standard token.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) internal balances_;

    mapping (address => mapping (address => uint256)) private allowed_;

    uint256 private totalSupply_;

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint256) {
        return balances_[_owner];
    }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
    function allowance(
        address _owner,
        address _spender
    )
      public
      view
      returns (uint256)
    {
        return allowed_[_owner][_spender];
    }

    /**
    * @dev Transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_value <= balances_[msg.sender],"Invalid value");
        require(_to != address(0),"Invalid address");

        balances_[msg.sender] = balances_[msg.sender].sub(_value);
        balances_[_to] = balances_[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    * Beware that changing an allowance with this method brings the risk that someone may use both the old
    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
    */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed_[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
    * @dev Transfer tokens from one address to another
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of tokens to be transferred
    */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
      public
      returns (bool)
    {
        require(_value <= balances_[_from],"Value is more than balance");
        require(_value <= allowed_[_from][msg.sender],"Value is more than alloved");
        require(_to != address(0),"Invalid address");

        balances_[_from] = balances_[_from].sub(_value);
        balances_[_to] = balances_[_to].add(_value);
        allowed_[_from][msg.sender] = allowed_[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
    function increaseApproval(
        address _spender,
        uint256 _addedValue
    )
      public
      returns (bool)
    {
        allowed_[msg.sender][_spender] = (allowed_[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed_[msg.sender][_spender]);
        return true;
    }

    /**
    * @dev Decrease the amount of tokens that an owner allowed to a spender.
    * approve should be called when allowed_[_spender] == 0. To decrement
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    * @param _spender The address which will spend the funds.
    * @param _subtractedValue The amount of tokens to decrease the allowance by.
    */
    function decreaseApproval(
        address _spender,
        uint256 _subtractedValue
    )
      public
      returns (bool)
    {
        uint256 oldValue = allowed_[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            allowed_[msg.sender][_spender] = 0;
        } else {
            allowed_[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed_[msg.sender][_spender]);
        return true;
    }

    /**
    * @dev Internal function that mints an amount of the token and assigns it to
    * an account. This encapsulates the modification of balances such that the
    * proper events are emitted.
    * @param _account The account that will receive the created tokens.
    * @param _amount The amount that will be created.
    */
    function _mint(address _account, uint256 _amount) internal {
        require(_account != 0,"Invalid address");
        totalSupply_ = totalSupply_.add(_amount);
        balances_[_account] = balances_[_account].add(_amount);
        emit Transfer(address(0), _account, _amount);
    }

    /**
    * @dev Internal function that burns an amount of the token of a given
    * account.
    * @param _account The account whose tokens will be burnt.
    * @param _amount The amount that will be burnt.
    */
    function _burn(address _account, uint256 _amount) internal {
        require(_account != 0,"Invalid address");
        require(_amount <= balances_[_account],"Amount is more than balance");

        totalSupply_ = totalSupply_.sub(_amount);
        balances_[_account] = balances_[_account].sub(_amount);
        emit Transfer(_account, address(0), _amount);
    }

    /**
    * @dev Internal function that burns an amount of the token of a given
    * account, deducting from the sender's allowance for said account. Uses the
    * internal _burn function.
    * @param _account The account whose tokens will be burnt.
    * @param _amount The amount that will be burnt.
    */
    function _burnFrom(address _account, uint256 _amount) internal {
        require(_amount <= allowed_[_account][msg.sender],"Amount is more than alloved");

        // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
        // this function needs to emit an event with the updated approval.
        allowed_[_account][msg.sender] = allowed_[_account][msg.sender].sub(_amount);
        _burn(_account, _amount);
    }
}


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    function safeTransfer(
        IERC20 _token,
        address _to,
        uint256 _value
    )
      internal
    {
        require(_token.transfer(_to, _value),"Transfer error");
    }

    function safeTransferFrom(
        IERC20 _token,
        address _from,
        address _to,
        uint256 _value
    )
      internal
    {
        require(_token.transferFrom(_from, _to, _value),"Tranfer error");
    }

    function safeApprove(
        IERC20 _token,
        address _spender,
        uint256 _value
    )
      internal
    {
        require(_token.approve(_spender, _value),"Approve error");
    }
}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable {
    event Paused();
    event Unpaused();

    bool public paused = false;


    /**
    * @dev Modifier to make a function callable only when the contract is not paused.
    */
    modifier whenNotPaused() {
        require(!paused,"Contract is paused, sorry");
        _;
    }

    /**
    * @dev Modifier to make a function callable only when the contract is paused.
    */
    modifier whenPaused() {
        require(paused, "Contract is running now");
        _;
    }

}


/**
 * @title Pausable token
 * @dev ERC20 modified with pausable transfers.
 **/
contract ERC20Pausable is ERC20, Pausable {

    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }
}

/**
 * @title Contract ATHLETICO token
 * @dev ERC20 compatible token contract
 */
contract ATHLETICOToken is ERC20Pausable {
    string public constant name = "ATHLETICO TOKEN";
    string public constant symbol = "ATH";
    uint32 public constant decimals = 18;
    uint256 public INITIAL_SUPPLY = 1000000000 * 1 ether; // 1 000 000 000
    address public CrowdsaleAddress;
    bool public ICOover;

    mapping (address => bool) internal kyc;


    constructor(address _CrowdsaleAddress) public {
    
        CrowdsaleAddress = _CrowdsaleAddress;
        _mint(_CrowdsaleAddress, INITIAL_SUPPLY);
    }


    modifier onlyOwner() {
        require(msg.sender == CrowdsaleAddress,"Only CrowdSale contract can run this");
        _;
    }
    
    modifier validDestination( address to ) {
        require(to != address(0x0),"Empty address");
        require(to != address(this),"RESTO Token address");
        _;
    }
    
    modifier isICOover {
        if (msg.sender != CrowdsaleAddress){
            require(ICOover == true,"Transfer of tokens is prohibited until the end of the ICO");
        }
        _;
    }
    
    /**
     * @dev Override for testing address destination
     */
    function transfer(address _to, uint256 _value) public validDestination(_to) isICOover returns (bool) {
        return super.transfer(_to, _value);
    }

    /**
     * @dev Override for testing address destination
     */
    function transferFrom(address _from, address _to, uint256 _value) 
    public validDestination(_to) isICOover returns (bool) 
    {
        return super.transferFrom(_from, _to, _value);
    }

    
/**
   * @dev Function to mint tokens
   * can run only from crowdsale contract
   * @param to The address that will receive the minted tokens.
   * @param value The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address to, uint256 value) public onlyOwner {
    _mint(to, value);
  }

  function setICOover() public onlyOwner {
    ICOover = true;
  }
    /**
     * @dev function transfer tokens from special address to users
     * can run only from crowdsale contract
     */
    function transferTokensFromSpecialAddress(address _from, address _to, uint256 _value) public onlyOwner whenNotPaused returns (bool){
        require (balances_[_from] >= _value,"Decrease value");
        
        balances_[_from] = balances_[_from].sub(_value);
        balances_[_to] = balances_[_to].add(_value);
        
        emit Transfer(_from, _to, _value);
        
        return true;
    }

    /**
     * @dev called from crowdsale contract to pause, triggers stopped state
     * can run only from crowdsale contract
     */
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Paused();
    }

    /**
     * @dev called from crowdsale contract to unpause, returns to normal state
     * can run only from crowdsale contract
     */
    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpaused();
    }

    function() external payable {
        revert("The token contract don`t receive ether");
    }  
}



/**
 * @title Ownable
 * @dev The Ownable contract has an owner and manager addresses, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;
    address public manager;
    address candidate;

    constructor() public {
        owner = msg.sender;
        manager = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner,"Access denied");
        _;
    }

    modifier restricted() {
        require(msg.sender == owner || msg.sender == manager,"Access denied");
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0),"Invalid address");
        candidate = _newOwner;
    }

    function setManager(address _newManager) public onlyOwner {
        require(_newManager != address(0),"Invalid address");
        manager = _newManager;
    }


    function confirmOwnership() public {
        require(candidate == msg.sender,"Only from candidate");
        owner = candidate;
        delete candidate;
    }

}


contract TeamAddress {
    function() external payable {
        revert("The contract don`t receive ether");
    } 
}


contract BountyAddress {
    function() external payable {
        revert("The contract don`t receive ether");
    } 
}


/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale
 */
contract Crowdsale is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for ATHLETICOToken;

    event LogStateSwitch(State newState);
    event Refunding(address indexed to, uint256 amount);
    mapping(address => uint) public crowdsaleBalances;

    uint256 softCap = 250 * 1 ether;
    address myAddress = this;
    ATHLETICOToken public token = new ATHLETICOToken(myAddress);
    uint64 crowdSaleStartTime = 1543622400;       // 01.12.2018 0:00:00
    uint64 crowdSaleEndTime = 1559347200;       // 01.06.2019 0:00:00
    uint256 minValue = 0.005 ether;

    //Addresses for store tokens
    TeamAddress public teamAddress = new TeamAddress();
    BountyAddress public bountyAddress = new BountyAddress();
      
    // How many token units a buyer gets per wei.
    uint256 public rate;

    // Amount of wei raised
    uint256 public weiRaised;

    event Withdraw(
        address indexed from, 
        address indexed to, 
        uint256 amount
    );

    event TokensPurchased(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );

    // Create state of contract
    enum State { 
        Init,    
        CrowdSale,
        Refunding,
        WorkTime
    }

    State public currentState = State.Init;

    modifier onlyInState(State state){ 
        require(state==currentState); 
        _; 
    }


    constructor() public {
        uint256 totalTokens = token.INITIAL_SUPPLY();
        /**
        * @dev Inicial distributing tokens to special adresses
        * TeamAddress - 10%
        * BountyAddress - 5%
        */
        _deliverTokens(teamAddress, totalTokens.div(10));
        _deliverTokens(bountyAddress, totalTokens.div(20));

        rate = 20000;
        setState(State.CrowdSale);
    }


    function finishCrowdSale() public onlyOwner onlyInState(State.CrowdSale) {
        require(now >= crowdSaleEndTime || myAddress.balance >= softCap, "Too early");
        if(myAddress.balance >= softCap) {
        setState(State.WorkTime);
        token.setICOover();
        } else {
        setState(State.Refunding);
        }
    }


    /**
    * @dev fallback function
    */
    function () external payable {
        buyTokens(msg.sender);
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

        crowdsaleBalances[_beneficiary] = crowdsaleBalances[_beneficiary].add(weiAmount);
        
        emit TokensPurchased(
            msg.sender,
            _beneficiary,
            weiAmount,
            tokens
        );

    }


    function setState(State _state) internal {
        currentState = _state;
        emit LogStateSwitch(_state);
    }


    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pauseCrowdsale() public onlyOwner {
        token.pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpauseCrowdsale() public onlyOwner {
        token.unpause();
    }

    /**
     * @dev called by the owner to set new rate
     */
    function setRate(uint256 _newRate) public onlyOwner {
        rate = _newRate;
    }


    /**
     * @dev the function tranfer tokens from TeamAddress1 to investor
     */
    function transferTokensFromTeamAddress(address _investor, uint256 _value) public restricted returns(bool){
        token.transferTokensFromSpecialAddress(address(teamAddress), _investor, _value); 
        return true;
    } 

    
    /**
     * @dev the function tranfer tokens from BountyAddress to investor
     */
    function transferTokensFromBountyAddress(address _investor, uint256 _value) public restricted returns(bool){
        token.transferTokensFromSpecialAddress(address(bountyAddress), _investor, _value); 
        return true;
    } 
    
    /**
    * @dev Validation of an incoming purchase. 
    * @param _beneficiary Address performing the token purchase
    * @param _weiAmount Value in wei involved in the purchase
    */
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal view{
        require(_beneficiary != address(0),"Invalid address");
        require(_weiAmount >= minValue,"Min amount is 0.005 ether");
        require(currentState != State.Refunding, "Only for CrowdSale and Work stage.");
    }

    /**
    * @dev internal function
    * @param _beneficiary Address performing the token purchase
    * @param _tokenAmount Number of tokens to be emitted
    */
    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
        token.safeTransfer(_beneficiary, _tokenAmount);
    }


    /**
     * @dev Function transfer token to new investors
     * Access restricted owner
     */ 
    function transferTokens(address _newInvestor, uint256 _tokenAmount) public onlyOwner {
        _deliverTokens(_newInvestor, _tokenAmount);
    }

    /**
     * @dev Function mint tokens to winners or prize funds contracts
     * Access restricted owner
     */ 
    function mintTokensToWinners(address _address, uint256 _tokenAmount) public onlyOwner {
        require(currentState == State.WorkTime, "CrowdSale is not finished yet. Access denied.");
        token.mint(_address, _tokenAmount);
    }

    /**
    * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
    * @param _beneficiary Address receiving the tokens
    * @param _tokenAmount Number of tokens to be purchased
    */
    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
        _deliverTokens(_beneficiary, _tokenAmount);
        
    }


    /**
    * @dev this function is ether converted to tokens.
    * @param _weiAmount Value in wei to be converted into tokens
    * @return Number of tokens that can be purchased with the specified _weiAmount
    */
    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        uint256 bonus = 0;
        uint256 resultAmount = _weiAmount;


        /**
        * ICO bonus                        UnisTimeStamp 
        *                                  Start date       End date
        * 01.12.2018-01.01.2019 - 100%     1543622400       1546300800
        * 01.01.2019-01.02.2019 - 50%      1546300800       1548979200
        * 01.02.2019-01.03.2019 - 25%      1548979200       1551398400
        */
        if (now >= 1543622400 && now < 1546300800) {
            bonus = 100;
        }
        if (now >= 1546300800 && now < 1548979200) {
            bonus = 50;
        }
        if (now >= 1548979200 && now < 1551398400) {
            bonus = 25;
        }
        
        if (bonus > 0) {
            resultAmount += _weiAmount.mul(bonus).div(100);
        }
        return resultAmount.mul(rate);
    }

    function refund() public payable{
        require(currentState == State.Refunding, "Only for Refunding stage.");
        // refund ether to investors
        uint value = crowdsaleBalances[msg.sender]; 
        crowdsaleBalances[msg.sender] = 0; 
        msg.sender.transfer(value);
        emit Refunding(msg.sender, value);
    }



    function withdrawFunds (address _to, uint256 _value) public onlyOwner {
        require(currentState == State.WorkTime, "CrowdSale is not finished yet. Access denied.");
        require (myAddress.balance >= _value,"Value is more than balance");
        require(_to != address(0),"Invalid address");
        _to.transfer(_value);
        emit Withdraw(msg.sender, _to, _value);
    }

}