//Comapny 
let developFundPerc = 10; // mint token percent for Development Fund
let developFundPercPremim = 10; // pay token percent for Developement Fund in Premium events
let comMarketFundPerc = 5; // 5 if advisor exist or comMarketFundPerc + advisorPercMint + extraHostPercMint = 8 if advisor not exist
let moderatorsFundPerc = 2; // Moderators Fund percent to pay token
// HOST
let hostPercMint = 10; // mint token percent for host
let hostPerc = 4; // pay token percent for host
let extraHostPerc = 1; // if advisor exist we add extra coins to host
let extraHostPercMint = 1; // if advisor exist we add extra coins to host in mint token
// EXPERT
let expertPercMint = 10; // mint token percent for expert
let expertPerc = 4; // pay token percent for expert
let expertExtraPerc = 2; // extra pay token parcent for expert if advisor not exist
let expertPremiumPerc = 15; // bty percent in premium events for experts
// ADVISORS
let advisorPercMint = 2; // mint token parcent for advisor
let advisorPepc = 1; // pay token parcent for advisor
//Company addresses
let comMarketFundAddr = "0x6f37EBfbbc32238b479de419A4fa477957f2f02d";
let moderatorsFundAddr = "0x3C7492FeDbd8b0D666fc42c907037F18c4e72B01";


module.exports = {
    developFundPerc,
    developFundPercPremim,
    comMarketFundPerc,
    moderatorsFundPerc,
    hostPercMint,
    hostPerc,
    extraHostPerc,
    extraHostPercMint,
    expertPercMint,
    expertPerc,
    expertExtraPerc,
    expertPremiumPerc,
    advisorPercMint,
    advisorPepc,
    comMarketFundAddr,
    moderatorsFundAddr
}