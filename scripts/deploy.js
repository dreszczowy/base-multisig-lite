// Deploy MultiSigWallet example

async function main() {
  const owners = [
    '0xYourOwner1',
    '0xYourOwner2',
    '0xYourOwner3'
  ];
  const required = 2;

  const MultiSig = await ethers.getContractFactory('MultiSigWallet');
  const multisig = await MultiSig.deploy(owners, required);
  await multisig.waitForDeployment();
  console.log('Multisig deployed:', await multisig.getAddress());
}

main();
