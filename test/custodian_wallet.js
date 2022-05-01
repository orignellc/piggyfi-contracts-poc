const { utils } = require("ethers");

const Factory = artifacts.require("Factory");
const USDC = artifacts.require("USDC");
const Escrow = artifacts.require("Escrow");

contract("CustodianWalletLogic", function ([deployer, account2]) {
  before(async function () {
    this.factory = await Factory.deployed();
    this.usdc = await USDC.deployed();
    this.escrow = await Escrow.deployed();

    this.escrow.setUsdcTokenAddress(this.usdc.address);

    const uniqueIdA = "1b9d6bcd-bbfd-4b2d-9b5d-ab8dfbbd4bed";
    const uniqueIdB = "2b9d6bcd-bbfd-4b2d-9b5d-ab8dfbbd4bed";
    const uniqueIdC = "3b9d6bcd-bbfd-4b2d-9b5d-ab8dfbbd4bed";
    const uniqueIdD = "4b9d6bcd-bbfd-4b2d-9b5d-ab8dfbbd4bed";

    // Create custodian wallets
    await this.factory.newCustodian(uniqueIdA); // vendorA  Operating from Nigeria. providing USDC / NGN pairs
    await this.factory.newCustodian(uniqueIdB); // vendorB  Operating from Kenya. providing USDC / KHS pairs
    await this.factory.newCustodian(uniqueIdC); // customerA sending NGN from Nigeria to Kenya
    await this.factory.newCustodian(uniqueIdD); // customerB receiving USD(USDC) from customerA. Converting it to Kenyan KHS

    // Get custodian wallets
    this.vendorA = await this.factory.accounts(uniqueIdA);
    this.vendorB = await this.factory.accounts(uniqueIdB);
    this.custodianWalletA = await this.factory.accounts(uniqueIdC);
    this.custodianWalletB = await this.factory.accounts(uniqueIdD);

    // Fund vendorA custodian wallet
    await this.usdc.transfer(this.vendorA, utils.parseEther("200"));

    // Remittance flow lifecycle
    //Step 1: customerA -> NGN(offchain) -> vendorA
    //Step 2: vendorA -> USDC(onchain) -> customerA     (Escrow charge fees from here)
    //Step 3: customerA -> USDC(onchain) -> customerB
    //Step 4: vendorB -> KHS(ofchain) -> customerB
    //Step 5: customerB -> USDC(ofchain) -> vendorB    (Escrow charge fees from here)
  });

  it("should assert that vendorA has 200 USDC to start remittance flow", async function () {
    const balance = await this.usdc.balanceOf(this.vendorA);

    return assert.equal(balance.toString(), utils.parseEther("200").toString());
  });
});
