import React, { useState, useEffect } from "react";
import { getWeb3, getContracts } from './utils.js';
import Header from './Header.js';
import Footer from './Footer.js';
import Wallet from './Wallet.js';
import NewOrder from './NewOrder.js';
import OrderList from './OrderList.js';
import TradeList from './TradeList.js';
import { unstable_renderSubtreeIntoContainer } from "react-dom";

function UniCyclone() {
    const [web3, setWeb3] = useState(undefined);
    const [contracts, setContracts] = useState(undefined);
    const [tokens, setTokens] = useState([]);
    const [user, setUser] = useState({
        accounts: [],
        balances: {
            tokenDex: 0,
            tokenWallet:0
        },
        selectedToken: undefined
    });
    const [orders, setOrders] = useState([]);

    const getBalances = async (account, token) => {
        const tokenDex = await contracts.dex.methods
        .balanceOf(account, web3.utils.fromAscii(token.symbol))
        .call();
        const tokenWallet = await contracts[token.symbol].methods
        .balanceOf(account)
        .call();
    }

    const selectToken = async token => {
        const balances await getBalances(accounts[0], token);
    }
}