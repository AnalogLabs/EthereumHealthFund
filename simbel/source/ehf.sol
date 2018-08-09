pragma solidity ^0.4.0;

contract owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

contract TokenERC20 {
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalSupply;

    // This creates an array with all balances
    mapping (address => uint256) public token_balance;  // NFO coin token balance on main net
    mapping (address => uint256)  public eth_balance;   // associates Ethereum deposited on main net with main net addrress
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);

    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of
the contract
     */
    constructor (
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public payable {
// Update total supply with the decimal amount
totalSupply = initialSupply * 10 ** uint256(decimals);

// Give the creator all initial tokens
token_balance[msg.sender] = totalSupply;

// initialize Ether balance of NFO Coin contract
eth_balance[msg.sender] = msg.value;
// Set the name for display purposes

name = tokenName;
// Set the symbol for display purposes
symbol = tokenSymbol;
}

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer_token(address _from, address _to, uint _value)
internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        // Check if the sender has enough
        require(token_balance[_from] >= _value);
        // Check for overflows
        require(token_balance[_to] + _value > token_balance[_to]);
        // Save this for an assertion in the future
        uint previousBalances = token_balance[_from] + token_balance[_to];
        // Subtract from the sender
        token_balance[_from] -= _value;
        // Add the same to the recipient
        token_balance[_to] += _value;
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(token_balance[_from] + token_balance[_to] ==
previousBalances);
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer_token(address _to, uint256 _value) public {
        _transfer_token(msg.sender, _to, _value);
    }

    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` in behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer_token_from(address _from, address _to, uint256
_value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer_token(_from, _to, _value);
        return true;
    }

    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens in your
behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /**
     * Set allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_value` tokens in your
behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved
contract
     */

    

    /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public returns (bool success) {
        require(token_balance[msg.sender] >= _value);   // Check if the sender has enough
        token_balance[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }

    /**
     * Destroy tokens from other account
     *
     * Remove `_value` tokens from the system irreversibly on behalf of
`_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public returns (bool
success) {
        require(token_balance[_from] >= _value);                // Check if  the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        token_balance[_from] -= _value;                         // Subtractvfrom the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        emit Burn(_from, _value);
        return true;
    }
}

/******************************************/
/*       ADVANCED TOKEN STARTS HERE       */
/******************************************/

contract ehf is owned, TokenERC20 {


        /* This generates a public event on the blockchain that will notify clients */
        event FrozenFunds(address target, bool frozen);

        uint master_exchange_rate;
        string[7] greetings;
        
        
    /* Initializes contract with initial supply tokens to the creator of
the contract */
    constructor (
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) TokenERC20(initialSupply, tokenName, tokenSymbol) public payable  {

        master_exchange_rate = 1000;                        // 1 ETH = 1000 FC

        greetings[0] = "Howdy, my name is Omar Metwally.";
        greetings[1] = "I am the creator of this contract.";
	greetings[2] = "Healthcare is a human right!";
	greetings[3] = "Go Blue!";
	greetings[4] = "I pledge to work tirelessly toward the goal of universal healthcare for all.";
	greetings[5] = "To the future machine with the computational power to unlock today's encrypted secret's.";
	greetings[6] = "To the future human with the spiritual power to unlock all secrets.";
    }    
    
	
        mapping (address => bool) frozenAccount;

        struct RequestForService {
	    string description;
	    uint max_amount;
	    uint bid_start_time;
	    uint bid_end_time;
	    address buyer;  // party that started the rfs
	    RequestState state; 

	    address lowest_bidder;	
	    uint lowest_bid; 

        }

        enum RequestState { OPEN, ACCEPTED, EXECUTED, CANCELED }
	
	mapping (address => RequestForService[]) public requests;
	mapping (address => uint)  pendingReturns;
	address[] public buyers;  // address-indexed list of parties that create requests for service 

	event RequestForServiceCreated(string description, uint max_amount, uint bid_start_time, uint bid_end_time, address buyer);

	event RequestForServiceAccepted(string description, uint max_amount, uint bid_start_time, uint bid_end_time, address buyer, address lowest_bidder, uint lowest_bid);

	event RequestForServiceExecuted(string description, uint max_amount, uint bid_start_time, uint bid_end_time, address buyer, address lowest_bidder, uint lowest_bid);

	event RequestForServiceCanceled(string description, uint max_amount, uint bid_start_time, uint bid_end_time, address buyer, address lowest_bidder, uint lowest_bid);
	event LowestBidDecreased(string description, uint max_amount, uint bid_start_time, uint bid_end_time, address buyer, address new_lowest_bidder, uint lowest_bid);

	modifier onlyBefore(uint _time) {require(now < _time); _; }
	modifier onlyAfter(uint _time) {require(now > _time); _; }



function new_request_for_service( string _description, uint _max_amount, uint _bid_start_time, uint _bid_end_time ) public {

	require ( now < _bid_start_time, "Bid must start in the future.");
	require ( now < _bid_end_time, "Bid has already ended." );
	require ( _bid_end_time > _bid_start_time, "Bid end time must occur after the start time.");


	requests[msg.sender].push(RequestForService( {
		description: _description,
		max_amount: _max_amount,
		bid_start_time: _bid_start_time,
		bid_end_time: _bid_end_time,
		buyer: msg.sender,
		state: RequestState.OPEN,
		lowest_bidder: msg.sender,
		lowest_bid: 0
		}));

	buyers.push (msg.sender );
	emit RequestForServiceCreated( _description, _max_amount, _bid_start_time, _bid_end_time, msg.sender);
 	
}

function cancel_rfs( uint8 rfs_index ) public {
    require( rfs_index < requests[msg.sender].length );
    requests[msg.sender][rfs_index].state = RequestState.CANCELED;
}

function get_rfs( address rfs_address, uint8 rfs_index) public view returns (string _description, uint _max_amount, uint _bid_start_time, uint _bid_end_time, address _buyer, RequestState _state, address _lowest_bidder, uint _lowest_bid) {

	RequestForService storage request = requests[rfs_address][rfs_index];
	
	_description = request.description;
	_max_amount = request.max_amount;
	_bid_start_time = request.bid_start_time;
	_bid_end_time = request.bid_end_time;
	_buyer = request.buyer;
	_state = request.state;
	_lowest_bidder = request.lowest_bidder;
	_lowest_bid = request.lowest_bid;
}

function get_rfs_count() public constant returns(uint _count) {
	return requests[msg.sender].length;
}

function make_offer(address rfs_address, uint8 rfs_index) public payable {

	// offer refers to this Request For Service (RFS):
	RequestForService storage rfs = requests[rfs_address][rfs_index];
    require ( rfs.state == RequestState.OPEN );
	require ( msg.value <  rfs.max_amount, "Offer amount exceeds RFS's maximum acceptable amount." );

	require ( msg.value > 0, "Offer amount must be greater than zero.");
	require ( (msg.value < rfs.lowest_bid) || (rfs.lowest_bid == 0) , "There is already a lower bid.");

	// if the above conditions are not satisfied, the contract does not receive msg.value
	// if all of the above conditions are satisfied...
	if ( rfs.lowest_bid != 0 ) {

		// allow the *previous* lowest_bidder to withdraw their funds
		// sending money back using rfs.lowest_bidder.send(rfs.lowest_bid) is
		// a security risk. Better to let recipients withdraw money themselves
		pendingReturns[rfs.lowest_bidder] += rfs.lowest_bid;
	}
	requests[rfs_address][rfs_index].lowest_bidder = msg.sender;
	requests[rfs_address][rfs_index].lowest_bid = msg.value;
	emit LowestBidDecreased(rfs.description, rfs.max_amount, rfs.bid_start_time, rfs.bid_end_time, rfs.buyer, rfs.lowest_bidder, rfs.lowest_bid);
	
}

// withdraw an offer that was overbid
function withdraw() public returns(bool) {

	uint amount = pendingReturns[msg.sender];
	if (amount > 0) {
		// important to set this to zero because the recipient
		// can call this function again as part of receiving call
		// before `send` returns
		pendingReturns[msg.sender] = 0; 
		
		if (!msg.sender.send(amount)) {
		    // no need to call throw here, just reset the amount owed
		    pendingReturns[msg.sender] = amount;
		    return false;
		}
	}
	return true;
}

// end the Request for Service but do not transfer lowest_bid to lowest_bidder
function end_rfs_bid( address rfs_address, uint8 rfs_index) public {

	RequestForService storage rfs = requests[rfs_address][rfs_index];
	require( now >= rfs.bid_end_time, "RFS has not yet expired.");
	
	emit RequestForServiceAccepted(rfs.description, rfs.max_amount, rfs.bid_start_time, rfs.bid_end_time, rfs.buyer, rfs.lowest_bidder, rfs.lowest_bid);	

	requests[rfs_address][rfs_index].state = RequestState.ACCEPTED;
}


// when a patient is registered, transfer lowest_bid amount to lowest_bidder
function execute_rfs( address rfs_address, uint8 rfs_index) public {

	RequestForService storage rfs = requests[rfs_address][rfs_index];
	require( rfs.state == RequestState.ACCEPTED );
	rfs.lowest_bidder.transfer(rfs.lowest_bid);
	requests[rfs_address][rfs_index].state = RequestState.EXECUTED;
	
	emit RequestForServiceExecuted( rfs.description, rfs.max_amount, rfs.bid_start_time, rfs.bid_end_time, rfs.buyer, rfs.lowest_bidder, rfs.lowest_bid);

}
	
function get_buyer_by_index(uint8 index) public constant returns (address _buyer)
{
	uint num_buyers = buyers.length;
	require( index < num_buyers ); 
	
	_buyer = buyers[index];

}

function get_num_buyers() public constant returns (uint _num_buyers) {

	_num_buyers = buyers.length;
}


    function get_eth_balance(address eth_addr) public constant returns
(uint balance) {
        return eth_balance[eth_addr];
    }

    function get_token_balance(address eth_addr) public constant returns
(uint balance) {
        return token_balance[eth_addr];
    }

    /* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead
        require (token_balance[_from] >= _value);               // Check if the sender has enough
        require (token_balance[_to] + _value > token_balance[_to]); // Check for overflows
        require(!frozenAccount[_from]);                     // Check if sender is frozen
        require(!frozenAccount[_to]);                       // Check if recipient is frozen
        token_balance[_from] -= _value;                         // Subtract from the sender
        token_balance[_to] += _value;                           // Add the same to the recipient
        emit Transfer(_from, _to, _value);
    }

    /// @notice Create `mintedAmount` tokens and send it to `target`
    /// @param target Address to receive the tokens
    /// @param mintedAmount the amount of tokens it will receive
    function mintToken(address target, uint256 mintedAmount) onlyOwner
public {
        token_balance[target] += mintedAmount;
        totalSupply += mintedAmount;
        emit Transfer(0, this, mintedAmount);
        emit Transfer(this, target, mintedAmount);
    }

    /// @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
    /// @param target Address to be frozen
    /// @param freeze either to freeze it or not
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

    /// @notice Buy tokens from contract by sending ether
    function buy() payable public {
        uint amount = msg.value * master_exchange_rate;  // buyPrice;
        // calculates the amount
        _transfer(owner, msg.sender, amount);
  // makes the transfers
        eth_balance[msg.sender] += msg.value;
 // update eth_balance
        token_balance[msg.sender] += amount;  // update token_balance
    }

    /// @notice Sell `amount` tokens to contract
    /// @param amount amount of tokens to be sold
    function sell(uint256 amount) public {
        require(eth_balance[this] >= (amount / master_exchange_rate) );      // checks if the contract has enough ether to buy
        _transfer(msg.sender, owner, amount);              // makes the transfers
        msg.sender.transfer(amount / master_exchange_rate);          // sends ether to the seller. It's important to do this last to avoid recursion attacks
        token_balance[msg.sender] -= amount;   // update token_balance
        eth_balance[msg.sender] -= (amount/master_exchange_rate) ;   // update eth_balance
    }

    function set_master_exchange_rate(uint new_rate) public  returns (uint
exchange_rate) {
        require(msg.sender == owner);
        master_exchange_rate = new_rate;
        return master_exchange_rate;
    }

    function greet_omar(uint _i) public constant returns (string greeting) {
        require(_i>=0);
        require(_i<greetings.length);
        return greetings[_i];
    }
}


