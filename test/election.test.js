const Registration = artifacts.require("Registration");

contract("Registration", (accounts) => {
  let registrationInstance;

  beforeEach(async () => {
    registrationInstance = await Registration.new(accounts[0]); // Przekazujemy konto jako electionContractAddress
  });

  it("should initialize with the correct election contract address", async () => {
    const electionContractAddress = await registrationInstance.electionContractAddress();
    assert.equal(electionContractAddress, accounts[0], "Incorrect election contract address");
  });

  it("should allow registration during the registration phase", async () => {
    await registrationInstance.register({ from: accounts[1] });
    const isRegistered = await registrationInstance.isParticipantRegistered(accounts[1]);
    assert.isTrue(isRegistered, "Participant should be registered");
  });

  it("should not allow registration after the registration phase ends", async () => {
    await registrationInstance.endRegistrationPhase();
    try {
      await registrationInstance.register({ from: accounts[1] });
      assert.fail("Registration should not be allowed after the registration phase ends");
    } catch (error) {
      assert.include(error.message, "revert", "Expected revert");
    }
  });

  it("should correctly track the participant count", async () => {
    await registrationInstance.register({ from: accounts[1] });
    await registrationInstance.register({ from: accounts[2] });
    const participantCount = await registrationInstance.getParticipantCount();
    assert.equal(participantCount, 2, "Incorrect participant count");
  });

  it("should emit the Register event when a participant is registered", async () => {
    const result = await registrationInstance.register({ from: accounts[1] });
    assert.equal(result.logs[0].event, "Register", "Register event not emitted");
    assert.equal(result.logs[0].args.newParticipant, accounts[1], "Incorrect participant address in Register event");
  });

  it("should emit the EndRegistrationPhase event when the registration phase ends", async () => {
    const result = await registrationInstance.endRegistrationPhase();
    assert.equal(result.logs[0].event, "EndRegistrationPhase", "EndRegistrationPhase event not emitted");
  });
});
