import Web3 from 'web3';
import contractInfo from '../build/contracts/ElectionFacade.json';

const web3 = new Web3(window.ethereum);

const contractAddress = contractInfo.networks['5777'].address;
const electionContractABI = contractInfo.abi;

const contract = new web3.eth.Contract(electionContractABI, contractAddress);

export const vote = async () => {
	let accounts = await web3.eth.requestAccounts();
	let account = accounts[0];

	const nomineeName = document.getElementById('VoteName').innerText;
	const [firstName, lastName] = nomineeName.split(' ');

	const nomineeAccount = findNomineeAccount(firstName, lastName);

  //get the gas price
  const gasPrice = await web3.eth.getGasPrice();

  if (nomineeAccount) {
	await contract.methods.vote(nomineeAccount).send({
    from: account,
    gas: 200000, //limit
    gasPrice: gasPrice,
  	});
   }
	
	reload();
}

const findNomineeAccount = (firstName, lastName) => {
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