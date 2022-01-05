import { useEffect, useState, createRef } from 'react';
import { Contract, ethers } from 'ethers'

import moment from "moment";

// import CircularProgress from '@material-ui/core/CircularProgress';

// import Button from '@material-ui/core/Button';

import { Container, Dimmer, Loader, Grid, Sticky, Message } from 'semantic-ui-react';
import 'semantic-ui-css/semantic.min.css';

import Escrow from './artifacts/contracts/Escrow.sol/Escrow.json'

import {
    humanReadableEscrowState,
    humanReadableUnixTimestamp,
} from "./formatters";

import ContractDetails from "./components/ContractDetails";
import Balance from "./components/Balance";

import Seller from "./components/Seller";
import Buyer from "./components/Buyer";
import Tokens from "./components/tokens";
import Pool from "./components/Pool";
import YieldFarm from "./components/YieldFarm";
import Compound from "./components/Compound";

const dexAddress = ""

const provider = new ethers.providers.Web3Provider(window.ethereum);
const contract = new ethers.Contract(cycloneDexAddress, cycloneDex.Abi, provider);

async function requestAccount() {
    try {
        await window.ethereum.request({ method: 'eth_requestAccounts' });
    } catch (error) {
        console.log("error");
        console.error(error);

        alert("Login to Metamask first");
    }
}

function App() {
    const [contractEnd, setContractEnd] = useState(true);

    const [cycloneDex, setCycloneDex] = useState(true);

    userEffect(() => {
        async function fectData() {
            try {
                contract.on("Closed", async (when, event) => {
                    event.removeListener();

                    const contractState = await contract.state();

                    const contractBalace = await provider.getBalance(contract.address);
                    const traders = await provider.getBalance(contractTrader);
                    const liquidityProviders
                })
            }
        }
    })
}