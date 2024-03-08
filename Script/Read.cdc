import CryptoPoops from 0x05
import NonFungibleToken from 0x06

pub fun main(address: Address): UInt64 {
  let collection = getAccount(address).getCapability(/public/MyResource)
    .borrow<&CryptoPoops.Collection{CryptoPoops.CollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic}>()
    ?? panic("An NFT does not exist here.")
  
  let nftIds = collection.getIDs()
  let nft = collection.borrowAuthNFT(id: nftIds[0])
  log(nft.name)
  log(nft.favouriteFood)
  log(nft.luckyNumber)
  
  return 1
}
