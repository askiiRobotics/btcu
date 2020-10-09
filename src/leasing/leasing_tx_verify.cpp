// Copyright (c) 2020 The BTCU developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#include "leasing/leasing_tx_verify.h"
#include "leasing/leasingmanager.h"

#ifdef ENABLE_LEASING_MANAGER

#include "script/standard.h"

#include "util.h"
#include "chain.h"

#include "consensus/validation.h"

bool ExtractLeasingPoint(const CTxOut& txOut, COutPoint& point, CKeyID& keyID) {
    std::vector<valtype> vSolutions;
    txnouttype whichType;
    if (Solver(txOut.scriptPubKey, whichType, vSolutions) && TX_LEASINGREWARD == whichType) {
        point.hash = uint256(vSolutions[0]);
        point.n = CScriptNum(vSolutions[1], true).getint();
        keyID = CKeyID(uint160(vSolutions[2]));
        return true;
    }
    return false;
}


bool CheckLeasingRewardTransaction(const CTransaction& tx, CValidationState& state, const CLeasingManager& leasingManager) {
    for (auto& txOut: tx.vout) {
        if (!txOut.IsLeasingReward())
            continue;

        COutPoint point;
        CKeyID keyID;
        if (!ExtractLeasingPoint(txOut, point, keyID))
            return state.DoS(10, error("CheckLeasingRewardTransaction(): no leasing point"), REJECT_INVALID, "bad-txns-leasing-point");


        auto calcTxOut = leasingManager.CalcLeasingReward(point, keyID);

        if (calcTxOut != txOut)
            return state.DoS(10, error("CheckLeasingRewardTransaction(): wrong leasing reward value"), REJECT_INVALID, "bad-txns-leasing-reward-value");
    }

    return true;
}

#endif // ENABLE_LEASING_MANAGER