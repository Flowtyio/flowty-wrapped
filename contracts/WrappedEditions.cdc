import "MetadataViews"
import "FlowtyWrapped"
import "StringUtils"

pub contract WrappedEditions {
    pub struct Wrapped2023Data {
        pub let address: Address
        pub let tickets: Int
        
        pub let totalNftsOwned: Int
        pub let floatCount: Int
        pub let favoriteCollections: [String] // type identifier of each collection
        pub let collections: [String]  // type identifier of each collection

        pub fun toTraits(): MetadataViews.Traits {
            let traits: [MetadataViews.Trait] = [
                WrappedEditions.buildTrait("address", self.address),
                WrappedEditions.buildTrait("tickets", self.tickets),
                WrappedEditions.buildTrait("totalNftsOwned", self.totalNftsOwned),
                WrappedEditions.buildTrait("floatCount", self.floatCount),
                WrappedEditions.buildTrait("favoriteCollections", self.favoriteCollections),
                WrappedEditions.buildTrait("collections", self.collections)
            ]
            
            return MetadataViews.Traits(traits)
        }

        init(_ address: Address, _ tickets: Int, totalNftsOwned: Int, floatCount: Int, favoriteCollections: [String], collections: [String]) {
            self.address = address
            self.tickets = tickets
            self.totalNftsOwned = totalNftsOwned
            self.floatCount = floatCount
            self.favoriteCollections = favoriteCollections
            self.collections = collections
        }
    }

    pub struct Edition2023: FlowtyWrapped.WrappedEdition {
        pub let name: String
        pub var supply: UInt64
        pub var baseImageUrl: String
        pub var baseHtmlUrl: String

        pub let raffleID: UInt64
        pub var status: String

        pub fun resolveView(_ t: Type, _ nft: &FlowtyWrapped.NFT): AnyStruct? {
            let wrapped = nft.data["wrapped"]! as! Wrapped2023Data
            switch t {
                case Type<MetadataViews.Display>():
                    return MetadataViews.Display(
                        name: "Flowty Wrapped 2023 #".concat(nft.serial.toString()),
                        description: "A celebration and statistical review of an exciting year on Flowty and across the Flow blockchain ecosystem.",
                        thumbnail: MetadataViews.HTTPFile(
                            url: self.baseImageUrl.concat(nft.serial.toString())
                        )
                    )
                case Type<MetadataViews.Editions>():
                    let editionYear = MetadataViews.Edition(name: "Flowty Wrapped 2023", number: nft.serial, max: nil)
                    let editionList: [MetadataViews.Edition] = [editionYear]
                    return MetadataViews.Editions(
                        editionList
                    )
                case Type<MetadataViews.Medias>():
                    let htmlMedia = MetadataViews.Media(
                        file: MetadataViews.IPFSFile("", nil), mediaType: "text/html"
                    )
                    let imageMedia = MetadataViews.Media(
                        file: MetadataViews.HTTPFile(url: self.baseImageUrl.concat(nft.serial.toString())), mediaType: "image/jpeg"
                    )
                    return MetadataViews.Medias([htmlMedia, imageMedia])
                case Type<MetadataViews.Traits>():
                    return wrapped.toTraits()
            }

            return nil
        }

        pub fun buildIpfsParams(_ data: Wrapped2023Data): String {
            var s = "?username=".concat(data.address.toString())
                .concat("&tickets=").concat(data.tickets.toString())
                .concat("&totalNftsOwned=").concat(data.totalNftsOwned.toString())
                .concat("&floatCount=").concat(data.floatCount.toString())
                .concat("&favoriteCollections=").concat(StringUtils.join(data.favoriteCollections, ","))
                .concat("&collections=").concat(StringUtils.join(data.collections, ","))
            
            return s
        }

        access(account) fun mint(data: {String: AnyStruct}): @FlowtyWrapped.NFT {
            self.supply = self.supply + 1
            let casted = data["wrapped"]! as! Wrapped2023Data

            let nft <- FlowtyWrapped.mint(id: FlowtyWrapped.totalSupply, serial: self.supply, editionName: self.name, data: data)

            // allocate raffle tickets
            let manager = FlowtyWrapped.getRaffleManager()
            let raffle = manager.borrowRaffle(id: self.raffleID)
                ?? panic("raffle not found in manager")
            
            let entries: [Address] = []
            var count = 0
            while count < casted.tickets {
                entries.append(casted.address)
            }
            raffle.addEntries(entries)

            return <- nft
        }

        pub fun getName(): String {
            return self.name
        }

        pub fun setStatus(_ s: String) {
            self.status = s
        }

        pub fun setBaseImageUrl(_ s: String) {
            self.baseImageUrl = s
        }

        pub fun setBaseHtmlUrl(_ s: String) {
            self.baseHtmlUrl = s
        }

        init(raffleID: UInt64, baseImageUrl: String, baseHtmlUrl: String) {
            self.name = "Flowty Wrapped 2023"
            self.supply = 0
            self.raffleID = raffleID
            self.baseImageUrl = baseImageUrl
            self.baseHtmlUrl = baseHtmlUrl

            self.status = "CLOSED"
        }
    }

    pub fun buildTrait(_ name: String, _ value: AnyStruct): MetadataViews.Trait {
        return MetadataViews.Trait(name: name, value: value, displayType: nil, rarity: nil)
    }
}