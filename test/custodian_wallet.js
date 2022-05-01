const CustodianWallet = artifacts.require("CustodianWallet");

contract("CustodianWallet", function ([deployer, account2]) {
  before(async function () {
    this.factory = await Factory.deployed();
    this.usdc = await USDC.deployed();
    this.escrow = await Escrow.deployed();

    this.factory.updateUsdcTokenAddress(this.usdc.address);

    const uniqueIdA = "1b9d6bcd-bbfd-4b2d-9b5d-ab8dfbbd4bed";
    const uniqueIdB = "2b9d6bcd-bbfd-4b2d-9b5d-ab8dfbbd4bed";
    const uniqueIdC = "3b9d6bcd-bbfd-4b2d-9b5d-ab8dfbbd4bed";

    await this.factory.newCustodian(uinqueIdA); // vendorA  Operating from Nigeria. providing USDC / NGN pairs
    await this.factory.newCustodian(uinqueIdB); // vendorB  Operating from Kenya. providing USDC / KHS pairs
    await this.factory.newCustodian(uinqueIdC); // customerA sending NGN from Nigeria to Kenya
    await this.factory.newCustodian(uinqueIdD); // customerB receiving USD(USDC) from customerA. Converting it to Kenyan KHS

    this.custodianWalletA = await this.factory.accounts(uniqueIdA);
    this.custodianWalletA = await this.factory.accounts(uniqueIdA);
    this.custodianWalletA = await this.factory.accounts(uniqueIdA);
  });
});
