// Copyright (c) 2009-2010 Satoshi Nakamoto
// Copyright (c) 2009-2014 The Bitcoin developers
// Copyright (c) 2015-2019 The BTCU developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#include "activemasternode.h"
#include "chainparams.h"
#include "db.h"
#include "init.h"
#include "main.h"
#include "masternode-budget.h"
#include "masternode-payments.h"
#include "masternodeconfig.h"
#include "masternodeman.h"
#include "messagesigner.h"
#include "rpc/server.h"
#include "utilmoneystr.h"

#include <univalue.h>
#include <consensus/validator_tx_verify.h>

void SendMoney(const CTxDestination& address, CAmount nValue, CWalletTx& wtxNew, bool fUseIX = false,
        const std::vector<CValidatorRegister> &validatorRegister = std::vector<CValidatorRegister>(),
        const std::vector<CValidatorVote> &validatorVote = std::vector<CValidatorVote>());

boost::optional<CKey> GetCollateralKey(CMasternode *pmn)
{
    boost::optional<CKey> keyOpt;
    CKey key;
    
    auto addr = pmn->pubKeyCollateralAddress.GetID(); // public key ID for MN's collateral address
    if (pwalletMain->GetKey(addr, key)) // get key (private and public parts) from wallet
    {
//        auto addr_str = CBTCUAddress(key.GetPubKey().GetID()).ToString();
        keyOpt.emplace(key);
    }
    return keyOpt;
}

boost::optional<std::pair<CTxIn, CKey>> GetVinKey(const std::string &strAlias)
{
    boost::optional<std::pair<CTxIn, CKey>> vinKeyOpt;
    
    for (CMasternodeConfig::CMasternodeEntry &mne : masternodeConfig.getEntries())
    {
        if( strAlias == mne.getAlias())
        {
            CKey keyMasternode;
            CPubKey pubKeyMasternode;
            
            if(CMessageSigner::GetKeysFromSecret(mne.getPrivKey(), keyMasternode, pubKeyMasternode))
            {
                CMasternode *pmn = mnodeman.Find(pubKeyMasternode);
                if(pmn != nullptr)
                {
                    auto keyOpt = GetCollateralKey(pmn);
                    if(keyOpt.is_initialized())
                    {
                        vinKeyOpt.emplace(std::pair<CTxIn, CKey>(pmn->vin, keyOpt.value()));
                    }
                    break;
                }
            }
        }
    }
    return vinKeyOpt;
}

// Tries to get secret key which corresponds to one of genesis validators keys
boost::optional<std::pair<CTxIn, CKey>> GetGenesisVinKey()
{
    boost::optional<std::pair<CTxIn, CKey>> vinKeyOpt;
    
    auto genesisValidators = Params().GenesisBlock().vtx[0].validatorRegister;
    for(auto &gv : genesisValidators)
    {
        CKey key;
        if(pwalletMain->GetKey(gv.pubKey.GetID(), key))
        {
            vinKeyOpt.emplace(std::pair<CTxIn, CKey>(gv.vin, key));
            break;
        }
    }
    return vinKeyOpt;
}

boost::optional<CValidatorRegister> CreateValidatorReg(const std::string &strAlias)
{
    boost::optional<CValidatorRegister> valRegOpt;
    
    auto keyOpt = GetVinKey(strAlias);
    if(keyOpt.is_initialized())
    {
        auto vinKey = keyOpt.value();
        
        CValidatorRegister valReg(vinKey.first, vinKey.second.GetPubKey());
        if(valReg.Sign(vinKey.second))
        {
            valRegOpt.emplace(valReg);
        }
    }
    return valRegOpt;
}

boost::optional<CValidatorVote> CreateValidatorVote(const std::string &strAlias, const std::vector<MNVote> &votes)
{
    boost::optional<CValidatorVote> valVoteOpt;
    
    auto keyOpt = GetVinKey(strAlias);
    if(keyOpt.is_initialized())
    {
        auto vinKey = keyOpt.value();
        
        CValidatorVote valVote(vinKey.first, vinKey.second.GetPubKey(), votes);
        if(valVote.Sign(vinKey.second))
        {
            valVoteOpt.emplace(valVote);
        }
    }
    return valVoteOpt;
}

// Votes generator for testing purposes
std::vector<MNVote> SetVotes()
{
    auto validatorsRegistrationList = g_ValidatorsState.get_registrations();
    
    std::vector<MNVote> votes;
    for(auto &valReg : validatorsRegistrationList)
    {
        votes.emplace_back(valReg.vin, VoteYes);
    }
    return votes;
}

UniValue CreateAndSendTransaction(const boost::optional<CValidatorRegister> &valRegOpt, const boost::optional<CValidatorVote> &valVoteOpt)
{
    if(valRegOpt.is_initialized() && valVoteOpt.is_initialized())
    {
        return UniValue("transaction can't be for registration and for voting at the same time");
    }
    
    std::vector<CValidatorRegister> valReg;
    std::vector<CValidatorVote> valVote;
    
    if(valRegOpt.is_initialized()){
        valReg.push_back(valRegOpt.value());
    }
    else if(valVoteOpt.is_initialized()){
        valVote.push_back(valVoteOpt.value());
    }
    
    // Get own address from wallet to send btcu to
    CReserveKey reservekey(pwalletMain);
    CPubKey vchPubKey;
    assert(reservekey.GetReservedKey(vchPubKey));
    CTxDestination myAddress = vchPubKey.GetID();
    
    CAmount nAmount = AmountFromValue(UniValue((double)1/COIN)); // send 1 satoshi
    CWalletTx wtx;
    
    EnsureWalletIsUnlocked();
    // Create and send transaction
    SendMoney(myAddress, nAmount, wtx, false, valReg, valVote);
    
    // Get hash of the created transaction
    return UniValue(wtx.GetHash().GetHex());
}

// TODO: This is a simplified version for testing purposes. The input parameters parsing and signing process should be implemented similarly to the 'mnbudgetvote'
UniValue mnregvalidator(const UniValue& params, bool fHelp)
{
    // Here we create transaction that contains CValidatorRegister and sends minimal amount of btcu to MN's own address.
    // This is needed to pay transaction fee to miner.
    
    UniValue ret(UniValue::VOBJ);
    int currentPositionInVotingPeriod = (chainActive.Height() + 1) % VALIDATORS_VOTING_PERIOD_LENGTH;  // +1 due to current transaction should be included at least into the next block
    
    // Checking that it is corresponding phase in the current voting period
    if((currentPositionInVotingPeriod >= VALIDATORS_REGISTER_START) &&
       (currentPositionInVotingPeriod <= VALIDATORS_REGISTER_END))
    {
        boost::optional<CValidatorRegister> valRegOpt = CreateValidatorReg("MN");
        if (valRegOpt.is_initialized()){
            ret = CreateAndSendTransaction(valRegOpt, boost::optional<CValidatorVote>());
        } else {
            ret = "CreateValidatorReg failed";
        }
    } else {
        ret = std::to_string(VALIDATORS_VOTING_PERIOD_LENGTH - currentPositionInVotingPeriod) + " blocks until start of the registration phase";
    }
    return ret;
}

// TODO: This is a simplified version for testing purposes. The input parameters parsing and signing process should be implemented similarly to the 'mnbudgetvote'
UniValue mnvotevalidator(const UniValue& params, bool fHelp)
{
    // Here we create transaction that contains CValidatorRegister and sends minimal amount of btcu to MN's own address.
    // This is needed to pay transaction fee to miner.
    
    UniValue ret(UniValue::VOBJ);
    int currentPositionInVotingPeriod = (chainActive.Height() + 1) % VALIDATORS_VOTING_PERIOD_LENGTH; // +1 due to current transaction should be included at least into the next block
    
    // Checking that it is corresponding phase in the current voting period
    if((currentPositionInVotingPeriod >= VALIDATORS_VOTING_START) &&
       (currentPositionInVotingPeriod <= VALIDATORS_VOTING_END))
    {
        // TODO: set votes from given parameters
        auto votes = SetVotes();
        
        if(!votes.empty()){
            boost::optional<CValidatorVote> valVoteOpt = CreateValidatorVote(MN_ALIAS_NAME, votes);
            if (valVoteOpt.is_initialized()){
                ret = CreateAndSendTransaction(boost::optional<CValidatorRegister>(), valVoteOpt);
            } else {
                ret = "CreateValidatorVote failed";
            }
        } else {
            ret = "Votes are empty";
        }
    } else {
        ret = std::to_string(VALIDATORS_VOTING_START - currentPositionInVotingPeriod) + " blocks until start of the voting phase";
    }
    return ret;
}

UniValue mnregvalidatorlist(const UniValue& params, bool fHelp)
{
    auto validatorsRegistrationList = g_ValidatorsState.get_registrations();
    
    std::string valRegStr;
    for(auto &valReg : validatorsRegistrationList)
    {
        valRegStr += (valReg.vin.ToString() + "\n");
    }
    return UniValue(valRegStr);
}

UniValue mnvotevalidatorlist(const UniValue& params, bool fHelp)
{
    auto validatorsVotesList = g_ValidatorsState.get_votes();
    
    std::string valVoteStr;
    for(auto &valVote : validatorsVotesList)
    {
        valVoteStr += (valVote.vin.ToString() + "\n");
    }
    return UniValue(valVoteStr);
}

UniValue mnvalidatorlist(const UniValue& params, bool fHelp)
{
    auto validatorsList = g_ValidatorsState.get_validators();
    
    std::string valStr;
    for(auto &val : validatorsList)
    {
        valStr += (val.vin.ToString() + "\n");
    }
    return UniValue(valStr);
}