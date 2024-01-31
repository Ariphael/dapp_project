import Web3 from 'web3';
import contractInfo from '../build/contracts/Nomination.json';

const web3 = new Web3(window.ethereum);

const contractAddress = contractInfo.networks['5777'].address;
const endorsementContractABI = contractInfo.abi;

const contract = new web3.eth.Contract(endorsementContractABI, contractAddress);

export const endorse = async () => {
	let accounts = await web3.eth.requestAccounts();
	let account = accounts[0];

	const endorseeName = document.getElementById('EndorseeName').innerText;
	const [firstName, lastName] = endorseeName.split(' ');
    endorseeAccount = findNomineeAddress(firstName,lastName)

  //get the gas price
  const gasPrice = await web3.eth.getGasPrice();

	await contract.methods.endorse(endorseeAccount, firstName, lastName).send({
	from: account,
	gas: 200000, //limit
	gasPrice: gasPrice,
	});

	
	reload();
}

const findNomineeAddress = (firstName, lastName) => {
	return addressList.find(nominee => nominee.firstName === firstName && nominee.lastName === lastName);
  }

const reload = async () => {
	let accounts = await web3.eth.requestAccounts();
	let account = accounts[0];
	
	pageAccountAddress.innerText = account;

}

const main = async () => {
	reload();
}

main();