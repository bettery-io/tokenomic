// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import {PubStruct} from "../../struct/PubStruct.sol";
import {PublicEvents} from "./PublicEvents.sol";
import {MPStruct} from "../../struct/MPStruct.sol";
import {Libs} from "./Libs.sol";
import {MPConfig} from "../../config/MPConfig.sol";

contract MiddlePayment is Libs, MPConfig, MPStruct {
    PubStruct eventsData;
    PublicEvents PublicAddr;
    address pubAddr;

    event payToCompanies(int id, uint tokens, uint correctAnswer);
    event payToHost(int id, uint premDF, uint mintDF, uint mintCMF, uint mintMF);
    event payToExperts(int id, uint mintHost, uint payHost, uint mintAdv, uint payAdv);
    event payToPlayers(int id);
    event revertedEvent(int id, string purpose);

    function __MiddlePaymentInit( PublicEvents _addr ) public initializer {
        __MPStructInit();
        PublicAddr = _addr;
        pubAddr = address(_addr);
        eventsData = PubStruct(_addr);
    }

    function letsFindCorrectAnswer(int _id) public {
        require(msg.sender == owner, "owner only");
        uint bigValue = 0;
        uint candDub = 0;
        uint correctAnswer;
        uint questAmount = eventsData.getQuestAmount(_id);

        // find correct answer
        for (uint i = 0; i < questAmount; i++) {
            if (eventsData.getExpertAmount(_id, i) > bigValue) {
                bigValue = eventsData.getExpertAmount(_id, i);
                correctAnswer = i;
            } else if (eventsData.getExpertAmount(_id, i) == bigValue) {
                candDub = eventsData.getExpertAmount(_id, i);
            }
        }

        if (candDub == bigValue) {
            MPData[_id].reverted = true;
            revertPayment(_id, "duplicat expert");
        } else {
            MPData[_id].correctAnswer = correctAnswer;
            findLosersPool(correctAnswer, _id);
        }
    }

    function findLosersPool(uint correctAnswer, int _id) private {
        uint B;
        for (uint i = 0; i < eventsData.getPlayerAmount(_id, correctAnswer); i++) {
            B = B + eventsData.getPlayerTokens(_id, correctAnswer, i);
        }
        
        uint lP = eventsData.getPool(_id) - B;
        if (lP > 0 && B > 0) {
             MPData[_id].loserPool = lP;
            // calculate minted tokens
            uint tokens =
                calcMintedTokens(
                    PublicAddr.getGF(),
                    _id,
                    eventsData
                );
                
            MPData[_id].tokenMinted = tokens;
            emit payToCompanies(_id, tokens, correctAnswer);
        } else {
            revertedPayment(_id, "play chose one answer");
        }
    }

    function revertedPayment(int _id, string memory purpose)
        public
    {
        require(msg.sender == owner || msg.sender == pubAddr, "owner only or pub addr only");
        revertPayment(_id, purpose);
    }

    function revertPayment(int _id, string memory purpose) private {
        for (uint i = 0; i < eventsData.getQuestAmount(_id); i++) {
            for (uint z = 0; z < eventsData.getPlayerAmount(_id, i); z++) {
                require(
                    PublicAddr.pay(eventsData.getPlayerWallet(_id, i, z), eventsData.getPlayerTokens(_id, i, z)),
                    "revert bet"
                );
            }
        }
        MPData[_id].reverted = true;
        emit revertedEvent(_id, purpose);
    }

    function letsPayToCompanies(int _id) public {
        require(msg.sender == owner, "owner only");
        // pay to Development Fund
        uint premDF = 0;
        uint mintDF = getPercent(MPData[_id].tokenMinted, developFundPerc);
        require( PublicAddr.mint(owner, mintDF), "mint development fund" );
        if (eventsData.getPremiumAmount(_id) > 0) {
            premDF = getPercent(eventsData.getPremiumAmount(_id), developFundPercPremim );
            require(                
                PublicAddr.payBTY(owner, premDF),
                "premium pay development fund"
            );
        }
        // pay to Community Marketing Fund
        uint percentCMF = eventsData.getAdvisorAddr(_id) != address(0)
                ? comMarketFundPerc
                : comMarketFundPerc + extraHostPercMint + advisorPercMint;
        uint mintCMF = getPercent(MPData[_id].tokenMinted, percentCMF);         
        require(
            PublicAddr.mint(comMarketFundWallet, mintCMF),
            "mint community marketing fund"
        );

        uint mintMF = getPercent(MPData[_id].tokenMinted, moderatorsFundPerc);
        // pay to Moderators Fund
        require(
            PublicAddr.mint(moderatorsFundWallet, mintMF),
            "mint moderators fund"
        );
        emit payToHost(_id, premDF, mintDF, mintCMF, mintMF);
    }

    function letsPaytoHost(int _id) public {
        require(msg.sender == owner, "owner only");
        uint mintHost = 0;
        uint payHost = 0;
        uint mintAdv = 0;
        uint payAdv = 0;
        if (eventsData.getAdvisorAddr(_id) != address(0)) {
            // pay minted tokens
            mintHost = getPercent( MPData[_id].tokenMinted, hostPercMint + extraHostPercMint);
            require(
                PublicAddr.mint(eventsData.getHostAddr(_id), mintHost),
                "mint host with advisor"
            );
            mintAdv = getPercent(MPData[_id].tokenMinted, advisorPercMint);
            require(
                PublicAddr.mint(eventsData.getAdvisorAddr(_id), mintAdv),
                "mint to advisor"
            );
            // pay tokens
            payHost = getPercent(MPData[_id].loserPool, hostPerc + extraHostPerc);
            require(
                PublicAddr.pay(eventsData.getHostAddr(_id), payHost),
                "pay to host with advisor"
            );
            payAdv = getPercent(MPData[_id].loserPool, advisorPepc);
            require(
                PublicAddr.pay(eventsData.getAdvisorAddr(_id), payAdv),
                "pay to advisor"
            );
        } else {
            // mint to host
            mintHost = getPercent(MPData[_id].tokenMinted, hostPercMint);
            require(
                PublicAddr.mint(eventsData.getHostAddr(_id), mintHost),
                "mint to host"
            );
            payHost = getPercent(MPData[_id].loserPool, hostPerc);
            // pay to host
            require(
                PublicAddr.pay(eventsData.getHostAddr(_id), payHost),
                "pay to host"
            );
        }
        emit payToExperts(_id, mintHost, payHost, mintAdv, payAdv);
    }

    function letsPayToExperts(int _id) public {
        require(msg.sender == owner, "owner only");
        uint percent = eventsData.getAdvisorAddr(_id) != address(0)
                ? expertPerc
                : expertPerc + expertExtraPerc;
        uint correctAnswer = MPData[_id].correctAnswer;
        int allReputation = calcReput(_id, correctAnswer);

        for (uint i = 0; i < eventsData.getExpertAmount(_id, correctAnswer); i++ ) {
            int reputation = eventsData.getExpertReput(_id, correctAnswer, i);
            if (reputation >= 0) {
                address payable expertWallet = eventsData.getExpertWallet(_id, correctAnswer, i);

                // mint tokens
                uint amountMint = (getPercent(MPData[_id].tokenMinted, expertPercMint) * uint(reputation)) / uint(allReputation);
                require(PublicAddr.mint(expertWallet, amountMint), "mint exp");

                // pay tokens
                uint amount = (getPercent(MPData[_id].loserPool, percent) * uint(reputation)) / uint(allReputation);
                require(PublicAddr.pay(expertWallet, amount), "pay exp");

                // pay in premium events
                if (eventsData.getPremiumAmount(_id) > 0) {
                    uint premiumAmount = (getPercent(eventsData.getPremiumAmount(_id), expertPremiumPerc ) * uint(reputation)) / uint(allReputation);
                    require(PublicAddr.payBTY(expertWallet, premiumAmount),"prem pay exp");
                }
       
            }
        }
        emit payToPlayers(_id);
    }
    
    function calcReput(int _id, uint correctAnswer) private view returns(int) { 
        int allReputation = 0;
        for ( uint i = 0; i < eventsData.getExpertAmount(_id, correctAnswer); i++ ) {
            if ( eventsData.getExpertReput(_id, correctAnswer, i) >= 0 ) {
                allReputation = allReputation + eventsData.getExpertReput(_id, correctAnswer, i);
            }
        }
        return allReputation;
    }
}
