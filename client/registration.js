import Web3 from 'web3';
import contractInfo from '../build/contracts/Registration.json';

const web3 = new Web3(window.ethereum);

const contractAddress = contractInfo.networks['5777'].address;
const registrationContractABI = contractInfo.abi;

const contract = new web3.eth.Contract(registrationContractABI, contractAddress);

const pageAccountAddress = document.getElementById('pageAccountAddress');

export const register = async () => {
	let accounts = await web3.eth.requestAccounts();
	let account = accounts[0];
	
  //get the gas price
  const gasPrice = await web3.eth.getGasPrice();

	await contract.methods.register().send({
    from: account,
    gas: 200000, //limit
    gasPrice: gasPrice,
  });
	
	reload();
}

const reload = async () => {
	let accounts = await web3.eth.requestAccounts();
	let account = accounts[0];
	
    console.log('Account:', account);

	pageAccountAddress.innerText = account;

}

const main = async () => {
	//check if MetaMask is installed
    if (window.ethereum) {
        await window.ethereum.enable();  // Request account access
        const accounts = await web3.eth.getAccounts();
        console.log('Connected account:', accounts[0]);
    
        reload();
      } else {
        console.error('MetaMask not found. Please install MetaMask.');
      }
}

main();
