pragma solidity ^0.4.18;

//   __    __   ______   __    __     _____
//  /  \  /  | /      \ /  \  /  |   /     |
//  $$  \ $$ |/$$$$$$  |$$  \ $$ |   $$$$$ |
//  $$$  \$$ |$$ |__$$ |$$$  \$$ |      $$ |
//  $$$$  $$ |$$    $$ |$$$$  $$ | __   $$ |
//  $$ $$ $$ |$$$$$$$$ |$$ $$ $$ |/  |  $$ |
//  $$ |$$$$ |$$ |  $$ |$$ |$$$$ |$$ \__$$ |
//  $$ | $$$ |$$ |  $$ |$$ | $$$ |$$    $$/
//  $$/   $$/ $$/   $$/ $$/   $$/  $$$$$$/

// 彡(ﾟ)(ﾟ)
// 彡(^)(^)



/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization
 * control functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the
    * sender account.
    */
    function Ownable() public {
        owner = msg.sender;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}



/* ERC20 contract interface */
/* With ERC223 Extensions */
/* Fully backward compatible with ERC20 */
/* Recommended implementation used at https://github.com/Dexaran/ERC223-token-standard/tree/Recommended */
contract ERC20 {
    uint public totalSupply;

    // ERC223 and ERC20 functions and events
    function balanceOf(address who) public view returns (uint);
    function totalSupply() public view returns (uint256 _supply);
    function transfer(address to, uint value) public returns (bool ok);
    function transfer(address to, uint value, bytes data) public returns (bool ok);
    function transfer(address to, uint value, bytes data, string customFallback) public returns (bool ok);
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);

    // ERC223 functions
    function name() public view returns (string _name);
    function symbol() public view returns (string _symbol);
    function decimals() public view returns (uint8 _decimals);

    // ERC20 functions and events
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}



/*
 * Contract that is working with ERC223 tokens
 */
 contract ContractReceiver {

    struct TKN {
        address sender;
        uint value;
        bytes data;
        bytes4 sig;
    }

    function tokenFallback(address _from, uint _value, bytes _data) public pure {
      TKN memory tkn;
      tkn.sender = _from;
      tkn.value = _value;
      tkn.data = _data;
      uint32 u = uint32(_data[3]) + (uint32(_data[2]) << 8) + (uint32(_data[1]) << 16) + (uint32(_data[0]) << 24);
      tkn.sig = bytes4(u);

      /* tkn variable is analogue of msg variable of Ether transaction
      *  tkn.sender is person who initiated this token transaction   (analogue of msg.sender)
      *  tkn.value the number of tokens that were sent   (analogue of msg.value)
      *  tkn.data is data of token transaction   (analogue of msg.data)
      *  tkn.sig is 4 bytes signature of function
      *  if data of token transaction is a function execution
      */
    }
}

/*
 * NANJ is an ERC20 token with ERC223 Extensions
 */
contract BasicNANJ is ERC20, Ownable {
    using SafeMath for uint256;

    string public name = "NANJCOINtest";
    string public symbol = "NANJt";
    uint8  public decimals = 6;
    uint256 public totalSupply = 30000000000 * (10 ** 6);
    bool public tokenCreated = false;
    bool public mintingFinished = false;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping (address => uint256)) public allowance;
    mapping (address => bool) public frozenAccount;

    event FrozenFunds(address target, bool frozen);
    event Burn(address indexed burner, uint256 value);
    event Mint(address indexed to, uint256 amount);
    event MintFinished();


    // Constructor is called only once and can not be called again (Ethereum Solidity specification)
    function BasicNANJ(address Itch) public {
        // Security check in case EVM has future flaw or exploit to call constructor multiple times
        // Ensure token gets created once only
        require(tokenCreated == false);
        tokenCreated = true;

        owner = Itch;
        balanceOf[owner] = totalSupply;

        // Final sanity check to ensure owner balance is greater than zero
        require(balanceOf[owner] > 0);
    }


    function name() public view returns (string _name) {
        return name;
    }

    function symbol() public view returns (string _symbol) {
        return symbol;
    }

    function decimals() public view returns (uint8 _decimals) {
        return decimals;
    }

    function totalSupply() public view returns (uint256 _totalSupply) {
        return totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balanceOf[_owner];
    }


    /**
     * @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
     * @param target Address to be frozen
     * @param isFrozen either to freeze it or not
     */
    function freezeAccount(address target, bool isFrozen) onlyOwner public {
        frozenAccount[target] = isFrozen;
        FrozenFunds(target, isFrozen);
    }


    // Function that is called when a user or another contract wants to transfer funds
    function transfer(address _to, uint _value, bytes _data, string _custom_fallback) public returns (bool success) {
        require(!frozenAccount[msg.sender]);
        require(!frozenAccount[_to]);

        if (isContract(_to)) {
            if (balanceOf[msg.sender] < _value) revert();
            balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
            balanceOf[_to] = balanceOf[_to].add(_value);
            assert(_to.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data));
            Transfer(msg.sender, _to, _value, _data);
            return true;
        } else {
            return transferToAddress(_to, _value, _data);
        }
    }

    // Function that is called when a user or another contract wants to transfer funds
    function transfer(address _to, uint _value, bytes _data) public  returns (bool success) {
        require(!frozenAccount[msg.sender]);
        require(!frozenAccount[_to]);

        if (isContract(_to)) {
            return transferToContract(_to, _value, _data);
        } else {
            return transferToAddress(_to, _value, _data);
        }
    }

    // Standard function transfer similar to ERC20 transfer with no _data
    // Added due to backwards compatibility reasons
    function transfer(address _to, uint _value) public returns (bool success) {
        require(!frozenAccount[msg.sender]);
        require(!frozenAccount[_to]);

        bytes memory empty;
        if (isContract(_to)) {
            return transferToContract(_to, _value, empty);
        } else {
            return transferToAddress(_to, _value, empty);
        }
    }

    // assemble the given address bytecode. If bytecode exists then the _addr is a contract.
    function isContract(address _addr) private view returns (bool is_contract) {
        uint length;
        assembly {
            //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
        }
        return (length > 0);
    }

    // function that is called when transaction target is an address
    function transferToAddress(address _to, uint _value, bytes _data) private returns (bool success) {
        if (balanceOf[msg.sender] < _value) revert();
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        Transfer(msg.sender, _to, _value, _data);
        return true;
    }

    // function that is called when transaction target is a contract
    function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
        if (balanceOf[msg.sender] < _value) revert();
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        ContractReceiver receiver = ContractReceiver(_to);
        receiver.tokenFallback(msg.sender, _value, _data);
        Transfer(msg.sender, _to, _value, _data);
        return true;
    }


    /**
    * @dev Transfer tokens from one address to another
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of tokens to be transferred
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0));
        require(_value > 0);
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);

        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens in your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
      return allowance[_owner][_spender];
    }



    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        require(_value <= balanceOf[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balanceOf[burner] = balanceOf[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }


    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    /**
    * @dev Function to mint tokens
    * @param _to The address that will receive the minted tokens.
    * @param _amount The amount of tokens to mint.
    * @return A boolean that indicates if the operation was successful.
    */
    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balanceOf[_to] = balanceOf[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(address(0), _to, _amount);
        return true;
    }

    /**
     * @dev Function to stop minting new tokens.
     * @return True if the operation was successful.
     */
    function finishMinting() onlyOwner canMint public returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }




    // Function to distribute tokens to list of addresses by the provided amount
    function distributeAirdrop(address[] addresses, uint256 amount) public returns(bool) {
        require(addresses.length > 0);

        uint256 weiAmount = amount.mul(10 ** 6);
        uint256 totalAmount = weiAmount.mul(addresses.length);
        // Only proceed if there are enough tokens to be distributed to all addresses
        require(balanceOf[owner] >= totalAmount);
        for (uint i = 0; i < addresses.length; i++) {
            require(addresses[i] != 0x0);
            balanceOf[addresses[i]] = balanceOf[addresses[i]].add(weiAmount);
            Transfer(msg.sender, addresses[i], weiAmount);
        }
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(totalAmount);
        return true;
    }



    uint256 distributeAmount = 25000 * (10 ** 6);

    function setDistributeAmount(uint256 newDistributeAmount) onlyOwner public {
        distributeAmount = newDistributeAmount.mul(10 ** 6);
    }

    function autoDistribute() internal {
        require(!pauseDistribute);
        require(!frozenAccount[msg.sender]);
        require(balanceOf[owner] >= distributeAmount);
        require(msg.value >= 0);
        if(msg.value > 0) owner.transfer(msg.value);
        balanceOf[owner] = balanceOf[owner].sub(distributeAmount);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(distributeAmount);
        bytes memory empty;
        Transfer(owner, msg.sender, distributeAmount, empty);
    }

    bool pauseDistribute = false;

    function pauseDistributing(bool isPaused) onlyOwner public {
        pauseDistribute = isPaused;
    }

    // fallback function
    function() payable public {
        autoDistribute();
     }

}

// Created by Tsuchinoko

// 　　 　 　 　/бヽ /бヽ
// 　　　　 　./　　/　　 /二ミﾍ
// 　　　　　 人_ _入_ _ノ ヾﾐﾐミミ
// 　　_＿＿／　　　　　　　　ﾐミミﾐﾐ
// 　 ヘ、　　　　　　　　　　  ヾﾐミﾐミ
// 　　　 ￣ヽ─～～-～-ヽ　　　　ヾﾐﾐﾐミ
// 　　　　　　 　 __＿ノ´　　　ヾﾐﾘミﾐミ
// 　　　　  ＜￣￣＿＿　　　　　  ヾミミｯミミ
// 　　　　　  ￣￣　　　＼　　　　ヾミミﾐミミ
