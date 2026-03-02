// scripts/deploy.js
const hre = require("hardhat");

async function main() {
  // Compila os contratos antes do deploy
  await hre.run("compile");

  // Obtém o contrato
  const Contract = await hre.ethers.getContractFactory("MyContract");

  // Faz o deploy
  const contract = await Contract.deploy();

  await contract.deployed();

  console.log("Contrato deployado em:", contract.address);
}

// Executa o script com tratamento de erros
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
`
