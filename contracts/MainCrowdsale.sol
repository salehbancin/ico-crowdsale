pragma solidity ^0.4.0;

import "zeppelin-solidity/contracts/crowdsale/RefundableCrowdsale.sol";
import "zeppelin-solidity/contracts/crowdsale/CappedCrowdsale.sol";
import "./Consts.sol";
import "./MainToken.sol";

contract MainCrowdsale is usingConsts, RefundableCrowdsale, CappedCrowdsale {

    function MainCrowdsale(
        uint _startTime,
        uint _endTime,
        uint _softCapEth,
        uint _hardCapEth,
        uint _rate,
        address _coldWalletAddress
    )
        Crowdsale(_startTime, _endTime, _rate, _coldWalletAddress)
        CappedCrowdsale(_hardCapEth * TOKEN_DECIMAL_MULTIPLIER)
        RefundableCrowdsale(_softCapEth * TOKEN_DECIMAL_MULTIPLIER)
    {
        require(_softCapEth <= _hardCapEth);
    }

    /**
     * @dev override token creation to integrate with MyWish token.
     */
    function createTokenContract() internal returns (MintableToken) {
        return new MainToken();
    }

    function hasStarted() public constant returns (bool) {
        return now >= startTime;
    }

    function finalization() internal {
        super.finalization();
        //#ifdef PAUSED
        MainToken(token).unpause();
        //#endif PAUSED
        MainToken(token).finishMinting();
        token.transferOwnership(owner);
    }
}
