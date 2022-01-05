import Web3 from 'web3';
import { ABI } from '../../config.js';
import { connectToDatabase } from '../../database.js';

const INFURA_ADDRESS = process.env.INFURA_ADDRESS;
const CONTRACT_ADDRESS = process.env.NEXT_PUBLIC_CONTRACT_ADDRESS;

const validInput = async(_input) => {
    try {
        let input = parseInt(_input);
        if (!(input >= 0 && < 10000)) {
            throw new RangeError("The argument must be between 0 and 9999");
        }
    } catch (e) {
        return false;
    }
};

const getMetadata = async (tokenId) => {
    let db = await connectToDatabase();
    return db.collection('metadata').find({"tokenId":tokenId}).toArray();
};

const uniCycloneApi = async (req, res) => {
    const query = req.query.id;
    const requestIsValid = await validInput(query);

    if (requestIsValid) {
        const provider = new Web3.providers.HttpProvider(INFURA_ADDRESS);
        const web3infura = new Web3(provider);
        const contract = new web3infura.eth.contract(ABI, CONTRACT_ADDRESS);

        const totalSupply = await contract.methods.totalSupply().call();
        console.log(totalSupply);

        if (parseInt(query) < totalSupply) {
            const trait = (await getMetadata(parseInt(query))) [0];
            let metadata = {};
            metadata = {
                
            }
        }
    }
}