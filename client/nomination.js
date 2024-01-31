import Web3 from 'web3';
import contractInfo from '../build/contracts/ElectionFacade.json';

const web3 = new Web3(window.ethereum);

const contractAddress = contractInfo.networks['5777'].address;
const nominationContractABI = contractInfo.abi;

const contract = new web3.eth.Contract(nominationContractABI, contractAddress);

export const nominate = async () => {
	let accounts = await web3.eth.requestAccounts();
	let account = accounts[0];

	const foundName = findNameByAddress(address);

	if (foundName){
		firstName=foundName.firstName;
		lastName=foundName.lastName;

		//get the gas price
  const gasPrice = await web3.eth.getGasPrice();

	await contract.methods.nominate(firstName, lastName).send({
	from: account,
	gas: 200000, //limit
	gasPrice: gasPrice,
	});
	}

	else {
		console.log("No nominee found with the given address.");
	}

  

	
	reload();
}

const findNameByAddress = (address) => {
    const nominee = addressList.find(nominee => nominee.address === address);
    if (nominee) {
        return { firstName: nominee.firstName, lastName: nominee.lastName };
    } else {
        return null; // or handle the case when no nominee is found with the given address
    }
};

const reload = async () => {
	let accounts = await web3.eth.requestAccounts();
	let account = accounts[0];
	
	pageAccountAddress.innerText = account;

}

const main = async () => {
	reload();
}

main();