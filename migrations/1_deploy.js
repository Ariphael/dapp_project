const electionArtifact = artifacts.require('ElectionFacade');
const bigVotingArtifact = artifacts.require('BigVoting');
const nominationArtifact = artifacts.require('Nomination');
const registrationArtifact = artifacts.require('Registration');

module.exports = async function(deployer) {
  await deployer.deploy(electionArtifact);
  await deployer.deploy(bigVotingArtifact, electionArtifact.address);
  await deployer.deploy(nominationArtifact, electionArtifact.address);
  await deployer.deploy(registrationArtifact, electionArtifact.address);

  const electionContractInstance = await electionArtifact.deployed();
  await electionContractInstance.setContractAddresses(
    bigVotingArtifact.address, 
    registrationArtifact.address, 
    nominationArtifact.address
  );
}