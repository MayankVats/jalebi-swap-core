async function main() {
  const Instance = await ethers.getContractFactory("JalebiFactory");
  const Factory = await Instance.deploy(
    "0xe81db2B45cf9C1A93a32A29c5bBC177B028Bfa6e"
  );

  console.log("Factory Deployed at: ", Factory.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
