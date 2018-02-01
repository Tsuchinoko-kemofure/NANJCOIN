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


// 彡(^)(^)「NANJのコードできたで～」
// 彡(ﾟ)(ﾟ)「Solidityってなんや？」
// 彡(´)(`)「よくわからないンゴ」


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



/* ERC20 contract interface
 * With ERC223 Extensions
 * Fully backward compatible with ERC20
 * Recommended implementation used at https://github.com/Dexaran/ERC223-token-standard/tree/Recommended
 */
contract ERC223 {
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
contract NANJ is ERC223, Ownable {
    using SafeMath for uint256;

    string public name = "NANJCOINtest4";
    string public symbol = "NANJt4";
    string public constant AAcontributor = "anonymous";
    uint8  public decimals = 8;
    uint256 public totalSupply = 30000000000 * 10 ** 8;
    bool public tokenCreated = false;
    bool public mintingFinished = false;

    address public preSeasonGame = 0x51fcc76D1444D280349d5d5F5a573A41E26Cf579;
    address public activityFunds = 0x58F4e99502679a381710cd29c115AB3d6aC77980;
    address public lockedFundsForthefuture = 0x911D1f1c8bB4aB4dBB7667De12F25a220889e60F;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping (address => uint256)) public allowance;
    mapping (address => bool) public frozenAccount;
    mapping (address => uint256) public unlockUnixTime;

    event FrozenFunds(address target, bool frozen);
    event LockedFunds(address target, uint256 locked);
    event Burn(address indexed burner, uint256 value);
    event Mint(address indexed to, uint256 amount);
    event MintFinished();


    // Constructor is called only once and can not be called again
    function NANJ(address Itch) public {
        // Security check in case EVM has future flaw or exploit to call constructor multiple times
        // Ensure token gets created once only
        require(tokenCreated == false);
        tokenCreated = true;

        owner = Itch;
        balanceOf[owner] = totalSupply.mul(25).div(100);
        balanceOf[preSeasonGame] = totalSupply.mul(55).div(100);
        balanceOf[activityFunds] = totalSupply.mul(10).div(100);
        balanceOf[lockedFundsForthefuture] = totalSupply.mul(10).div(100);

        require(balanceOf[owner] > 0);
        setPrice(90000000000);
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
     * @param targets Addresses to be frozen
     * @param isFrozen either to freeze it or not
     */
    function freezeAccounts(address[] targets, bool isFrozen) onlyOwner public {
        require(targets.length > 0);

        for (uint j = 0; j < targets.length; j++) {
            require(targets[j] != 0x0);
            frozenAccount[targets[j]] = isFrozen;
            FrozenFunds(targets[j], isFrozen);
        }
    }

    function lockupAccounts(address[] targets, uint[] unixTimes) onlyOwner public{
        require(targets.length > 0
                && targets.length == unixTimes.length);

        for(uint j = 0; j < targets.length; j++){
            require(unlockUnixTime[targets[j]] < unixTimes[j]);
            unlockUnixTime[targets[j]] = unixTimes[j];
            LockedFunds(targets[j], unixTimes[j]);
        }
    }

    function getUnixTime() public view returns(uint256) {
        uint256 currentUnixTime = now;
        return currentUnixTime;
    }


    // Function that is called when a user or another contract wants to transfer funds
    function transfer(address _to, uint _value, bytes _data, string _custom_fallback) public returns (bool success) {
        require(_value > 0
                && frozenAccount[msg.sender] == false
                && frozenAccount[_to] == false
                && now > unlockUnixTime[msg.sender]
                && now > unlockUnixTime[_to]);

        if (isContract(_to)) {
            require(balanceOf[msg.sender] >= _value);
            balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
            balanceOf[_to] = balanceOf[_to].add(_value);
            assert(_to.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data));
            Transfer(msg.sender, _to, _value, _data);
            Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return transferToAddress(_to, _value, _data);
        }
    }

    // Function that is called when a user or another contract wants to transfer funds
    function transfer(address _to, uint _value, bytes _data) public  returns (bool success) {
        require(_value > 0
                && frozenAccount[msg.sender] == false
                && frozenAccount[_to] == false
                && now > unlockUnixTime[msg.sender]
                && now > unlockUnixTime[_to]);

        if (isContract(_to)) {
            return transferToContract(_to, _value, _data);
        } else {
            return transferToAddress(_to, _value, _data);
        }
    }

    // Standard function transfer similar to ERC20 transfer with no _data
    // Added due to backwards compatibility reasons
    function transfer(address _to, uint _value) public returns (bool success) {
        require(_value > 0
                && frozenAccount[msg.sender] == false
                && frozenAccount[_to] == false
                && now > unlockUnixTime[msg.sender]
                && now > unlockUnixTime[_to]);

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
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        Transfer(msg.sender, _to, _value, _data);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    // function that is called when transaction target is a contract
    function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        ContractReceiver receiver = ContractReceiver(_to);
        receiver.tokenFallback(msg.sender, _value, _data);
        Transfer(msg.sender, _to, _value, _data);
        Transfer(msg.sender, _to, _value);
        return true;
    }



    /**
    * @dev Transfer tokens from one address to another
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of tokens to be transferred
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0)
                && _value > 0
                && balanceOf[_from] >= _value
                && allowance[_from][msg.sender] >= _value
                && frozenAccount[_from] == false
                && frozenAccount[_to] == false
                && now > unlockUnixTime[_from]
                && now > unlockUnixTime[_to]);

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
     * @param _from The address that will burn the tokens.
     * @param _amount The amount of token to be burned.
     */
    function burn(address _from, uint256 _amount) onlyOwner public {
        require(balanceOf[_from] >= _amount
                && _amount > 0);

        balanceOf[_from] = balanceOf[_from].sub(_amount);
        totalSupply = totalSupply.sub(_amount);
        Burn(_from, _amount);
        //Transfer(_from, address(0), _amount);
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
        require(_amount > 0);

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
        require(amount > 0
                && addresses.length > 0
                && frozenAccount[msg.sender] == false
                && now > unlockUnixTime[msg.sender]);

        uint256 weiAmount = amount.mul(10 ** 8);
        uint256 totalAmount = weiAmount.mul(addresses.length);
        require(balanceOf[msg.sender] >= totalAmount);

        for (uint j = 0; j < addresses.length; j++) {
            require(addresses[j] != 0x0
                    && frozenAccount[addresses[j]] == false
                    && now > unlockUnixTime[addresses[j]]);

            balanceOf[addresses[j]] = balanceOf[addresses[j]].add(weiAmount);
            Transfer(msg.sender, addresses[j], weiAmount);
        }
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(totalAmount);
        return true;
    }


    function distributeAirdrop(address[] addresses, uint[] amounts) public returns(bool) {
        require(addresses.length > 0
                && addresses.length == amounts.length
                && frozenAccount[msg.sender] == false
                && now > unlockUnixTime[msg.sender]);

        uint[] memory weiAmounts = new uint[](addresses.length);
        uint256 totalAmount = 0;
        for(uint j = 0; j < addresses.length; j++){
            weiAmounts[j] = amounts[j].mul(10 ** 8);
            totalAmount = totalAmount.add(weiAmounts[j]);
        }
        require(balanceOf[msg.sender] >= totalAmount);

        for (j = 0; j < addresses.length; j++) {
            require(weiAmounts[j] > 0
                    && addresses[j] != 0x0
                    && frozenAccount[addresses[j]] == false
                    && now > unlockUnixTime[addresses[j]]);

            balanceOf[addresses[j]] = balanceOf[addresses[j]].add(weiAmounts[j]);
            Transfer(msg.sender, addresses[j], weiAmounts[j]);
        }
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(totalAmount);
        return true;
    }


    function collectTokens(address[] addresses, uint[] amounts) onlyOwner public returns(bool) {
        require(addresses.length > 0
                && addresses.length == amounts.length);

        uint[] memory weiAmounts = new uint[](addresses.length);
        uint256 totalAmount = 0;

        for (uint j = 0; j < addresses.length; j++) {
            require(amounts[j] > 0
                    && addresses[j] != 0x0
                    && frozenAccount[addresses[j]] == false
                    && now > unlockUnixTime[addresses[j]]);

            weiAmounts[j] = amounts[j].mul(10 ** 8);
            require(balanceOf[addresses[j]] >= weiAmounts[j]);
            totalAmount = totalAmount.add(weiAmounts[j]);
            balanceOf[addresses[j]] = balanceOf[addresses[j]].sub(weiAmounts[j]);
            Transfer(addresses[j], msg.sender, weiAmounts[j]);
        }
        balanceOf[msg.sender] = balanceOf[msg.sender].add(totalAmount);
        return true;
    }


    uint256 public buyPrice;

    /**
     * @notice Allow users to buy tokens for `newBuyPrice` eth
     *  　　　and sell tokens for `newRefillPrice` eth
     * @param BuyPriceinWei Price users can buy from the contract
     */
    function setPrice(uint256 BuyPriceinWei) onlyOwner public {
        buyPrice = BuyPriceinWei;   // Ex. 1 NANJ = 10000wei
    }

    bool public buyingFinished = false;
    event BuyFinished();

    modifier canBuy() {
        require(!buyingFinished);
        _;
    }

    /// @notice Buy tokens from contract by sending ether
    function buyTokens() canBuy internal {
        require(buyPrice > 0
                && msg.value >= buyPrice
                && frozenAccount[msg.sender] == false
                && now > unlockUnixTime[msg.sender]);

        uint256 amount = msg.value.div(buyPrice).mul(10 ** 8);
        require(balanceOf[preSeasonGame] >= amount);

        balanceOf[preSeasonGame] = balanceOf[preSeasonGame].sub(amount);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(amount);
        preSeasonGame.transfer(msg.value);
        Transfer(preSeasonGame, msg.sender, amount);
    }

    function finishBuying() onlyOwner canBuy public returns (bool) {
        buyingFinished = true;
        BuyFinished();
        return true;
    }


    // fallback function
    function() payable public {
        buyTokens();
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
