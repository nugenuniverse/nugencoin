//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/// Partnership Smart Contract
contract Partnership is Ownable {
    event DistributionWalletInfo( 
        address indexed account, 
        uint amount, 
        uint time
    );

    event Claim( 
        address indexed claimer, 
        uint amount
    );
        event revokewallet(
        address indexed account
    );
    event periodclaim(
     uint subSequentPeriod
    );
    event claimpermonth(
      uint   subClaim
    );
    event cliffperiod(
      uint  _cliff
    );
    event Noofvest(
     uint _totalNumberOfVesting
    );

// setTotalNumberOfVesting
// setcliff
//  setSubClaimPerMonth
// setClaimPeriod


    mapping(address => userStruct) public user;

    struct userStruct {
        uint balance;
        uint totalClaimed;
        uint initiated;
        uint lastClaim;
    }

    IBEP20 public token;
    uint public subsequentClaim ;
    uint public totalNumberOfVesting;
    uint public releaseClaim ;
    uint public claimPeriod ;
    uint public cliff;
    uint[2] public total; //0- total allocated, 1- total claimed

    constructor(address tokenAdd,uint subsequentClaims, uint releaseClaims, uint vestingPeriod, uint cliffs, uint totalNumberOfVestings) {
        require(vestingPeriod > 0, "Partnership  : timestamp > 0");
        require(subsequentClaims> 0, "Partnership  : timestamp > 0");
         token = IBEP20(tokenAdd);
        claimPeriod = vestingPeriod;
        subsequentClaim = subsequentClaims;
        cliff = cliffs;
        releaseClaim = releaseClaims;
        totalNumberOfVesting = totalNumberOfVestings;
        
    }

    receive() external payable {
        revert("No receive calls");
    }

/// Set claim Period in seconds before distribution 
    function setClaimPeriod( uint subSequentPeriod) external onlyOwner {
        claimPeriod = (subSequentPeriod != 0) ? subSequentPeriod : claimPeriod;
    
    emit periodclaim(
          subSequentPeriod
    );
    }
/// Set subclaimPerMonth in percentage with 18 decimal before distribution
    function setSubClaimPerMonth( uint subClaim) external onlyOwner {
        subsequentClaim = (subClaim != 0) ? subClaim : subsequentClaim;
    emit claimpermonth(
          subClaim
    );
}
///  Set cliff period in seconds B/w claim 1 and claim 2 before distribution
     function setcliff( uint _cliff) external onlyOwner {
        cliff = _cliff;
    emit cliffperiod(
        _cliff
    );
     }

/// set Total Number Of Vesting before distribution
    function setTotalNumberOfVesting( uint _totalNumberOfVesting) external onlyOwner {
        totalNumberOfVesting = _totalNumberOfVesting;
    
    emit Noofvest(
        _totalNumberOfVesting
    );
    }

/// add distribution mention address, amount and local timestamp
    function addDistributionWallet( address[] memory account, uint[] memory amount, uint[] memory startTime) external onlyOwner {
        require(account.length < 250,"Partnership : length < 250");
        require((account.length == amount.length) && (startTime.length == amount.length),"Partnership : length mismatch");
        uint currentTime = block.timestamp;

        for(uint i=0; i< account.length; i++) {
                require ( account[i] != 0x0000000000000000000000000000000000000000, "remove the zero address");
            require((total[0] + amount[i]) <= token.balanceOf(address(this)), "Partnership : insufficient balance to allocate");
            require(startTime[i] > currentTime, "start time should be > current time");

            userStruct storage userStorage = user[account[i]];
            userStorage.balance += amount[i];
            total[0] += amount[i];
            
            if(userStorage.initiated == 0) {
                userStorage.initiated = startTime[i];
                userStorage.lastClaim = startTime[i];
            }
            
            emit DistributionWalletInfo( 
                account[i], 
                amount[i], 
                block.timestamp
            );
        }
    }

/// revoke distribution from beneficiary address , amount credit in admin wallet
    function revokeDistributionWallet(address[] memory account) external onlyOwner {
        require(account.length < 250,"Partnership : length < 250");

        for(uint i=0; i< account.length; i++) {  
            userStruct memory user_ = user[account[i]];   
            require(user_.totalClaimed < user_.balance, "Partnership : user claimed all funds or user may not be added");
            uint amountToRevoke = user_.balance - user_.totalClaimed;
            delete user[account[i]];

            if(amountToRevoke > 0) {
                require(token.balanceOf(address(this)) >= amountToRevoke, "Partnership : insufficient balance to revoke");
                require(token.transfer(owner(),amountToRevoke),"Partnership : revoke transfer failed");
            }
                  emit revokewallet(
                account[i]
            );
        }
    }

///only beneficiary wallet will claim after vesting start
    function claim() external {
        userStruct storage user_ = user[msg.sender];
        require(user_.balance > 0, "Partnership : user not exist");
        require(user_.totalClaimed < user_.balance, "Partnership : total claim < total balance");
        require((user_.lastClaim > 0) && (user_.lastClaim <= block.timestamp), "PartnershipL : lastClaim < block.timestamp");
       
        uint totDays;
        uint lastClaimTimestamp = user_.lastClaim;
        uint claimAmount;

        if(block.timestamp >= user_.initiated + cliff + (claimPeriod *  totalNumberOfVesting)) {
            user_.lastClaim += ( user_.initiated + cliff + (claimPeriod *  totalNumberOfVesting));
            claimAmount = user_.balance - user_.totalClaimed;
        }else if(user_.totalClaimed == 0){
            claimAmount = (user_.balance * releaseClaim) / 100e18;
            user_.lastClaim += cliff;
            if(block.timestamp > lastClaimTimestamp + cliff){
                totDays = (block.timestamp - lastClaimTimestamp - cliff) / claimPeriod;
                user_.lastClaim += claimPeriod * totDays;
                claimAmount += (user_.balance * (subsequentClaim * totDays)) / 100e18;
            } 
        }else{
        totDays = (block.timestamp - lastClaimTimestamp) / claimPeriod;
        user_.lastClaim += claimPeriod * totDays;
        
        claimAmount = (user_.balance * (subsequentClaim * totDays)) / 100e18;
        }
        

        if((user_.totalClaimed + claimAmount) > user_.balance) {
            claimAmount = user_.balance - user_.totalClaimed; 
        }
        require(claimAmount > 0, "Partnership : claimAmount is zero");
        user_.totalClaimed += claimAmount;
        total[1] += claimAmount;
        token.transfer(msg.sender, claimAmount);
        
        emit Claim(
            msg.sender,
            claimAmount
        );
    }

 
/// beneficiary amount show
 function rewardInfo( address account) external view returns (uint reward){
        userStruct memory user_ = user[account];

        if((user_.totalClaimed > user_.balance) || (user_.balance == 0) || ((user_.lastClaim ) > block.timestamp)) {
            return 0;
        }
        
        uint totDays;
        uint lastClaimTimestamp = user_.lastClaim;
        uint claimAmount;

        if(user_.totalClaimed == 0){
            claimAmount = (user_.balance * releaseClaim) / 100e18;
            if(block.timestamp > lastClaimTimestamp + cliff){
                totDays = (block.timestamp - lastClaimTimestamp - cliff) / claimPeriod;
                claimAmount += (user_.balance * (subsequentClaim * totDays)) / 100e18;
            } 
        }else{
        totDays = (block.timestamp - lastClaimTimestamp) / claimPeriod;
        
        claimAmount = (user_.balance * (subsequentClaim * totDays)) / 100e18;
        }

        if((user_.totalClaimed + claimAmount) > user_.balance) {
            claimAmount = user_.balance - user_.totalClaimed; 
        }

        return claimAmount;
    }

/// extra token withdraw by admin
    function failcase( address tokenAdd, uint amount) external onlyOwner{
        address self = address(this);
        if(tokenAdd == address(0)) {
            require(self.balance >= amount, "Partnership : insufficient balance");
            require(payable(owner()).send(amount), "Partnership : transfer failed");
        } else {
            require(IBEP20(tokenAdd).balanceOf(self) >= amount, "Partnership : insufficient balance");
            if(tokenAdd == address(token)){
                if(total[0] > total[1]) {
                    uint unClaimed = total[0] - total[1];
                    if(IBEP20(tokenAdd).balanceOf(self) > unClaimed) {
                        uint claimable = IBEP20(tokenAdd).balanceOf(self) - unClaimed;
                        if(amount > claimable) {
                            amount = 0;
                        }
                    } else {
                        amount = 0;
                    }
                }
                   require(amount > 0, "no available tokens to claim");
            }
            require(IBEP20(tokenAdd).transfer(owner(),amount), "Partnership : transfer failed");
        }
    }
}
