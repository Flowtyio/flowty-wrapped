import "NonFungibleToken"
import "MetadataViews"
import "ViewResolver"
import "FungibleToken"

pub contract FlowtyWrapped: NonFungibleToken, ViewResolver {

    // Total supply of FlowtyWrappeds
    pub var totalSupply: UInt64

    /// The event that is emitted when the contract is created
    pub event ContractInitialized()

    /// The event that is emitted when an NFT is withdrawn from a Collection
    pub event Withdraw(id: UInt64, from: Address?)

    /// The event that is emitted when an NFT is deposited to a Collection
    pub event Deposit(id: UInt64, to: Address?)

    /// Storage and Public Paths
    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    pub let CollectionProviderPath: PrivatePath
    pub let MinterStoragePath: StoragePath

    // We only have a public path for minting to let FlowtyWrappeds be like a faucet.
    pub let MinterPublicPath: PublicPath

    /// The core resource that represents a Non Fungible Token. 
    /// New instances will be created using the NFTMinter resource
    /// and stored in the Collection resource
    ///
    pub resource NFT: NonFungibleToken.INFT, MetadataViews.Resolver {

        /// The unique ID that each NFT has
        pub let id: UInt64
        pub let image: String
        pub let richHtml: String
        pub let ownerAddress: Address
        pub let data: {String: AnyStruct} // any extra data like a name or mint time

        init(
            id: UInt64,
            ownerAddress: Address
        ) {
            self.id = id
            self.image = "https://storage.googleapis.com/flowty-images/flowty-logo.jpeg"
            self.richHtml = ""
            self.ownerAddress = ownerAddress
            self.data = {}

            // We will add some Raffle entry logic here, probably 
        }

        /// Function that returns all the Metadata Views implemented by a Non Fungible Token
        ///
        /// @return An array of Types defining the implemented views. This value will be used by
        ///         developers to know which parameter to pass to the resolveView() method.
        ///
        pub fun getViews(): [Type] {
            return [
                Type<MetadataViews.Display>(),
                Type<MetadataViews.Medias>(),
                Type<MetadataViews.Royalties>(),
                Type<MetadataViews.Editions>(),
                Type<MetadataViews.ExternalURL>(),
                Type<MetadataViews.NFTCollectionData>(),
                Type<MetadataViews.NFTCollectionDisplay>(),
                Type<MetadataViews.Serial>(),
                Type<MetadataViews.Traits>()
            ]
        }

        /// Function that resolves a metadata view for this token.
        ///
        /// @param view: The Type of the desired view.
        /// @return A structure representing the requested view.
        ///
        pub fun resolveView(_ view: Type): AnyStruct? {
            assert(self.ownerAddress == self.owner!.address, message: "The NFT must be owned by the Collection's owner")

            switch view {
                case Type<MetadataViews.Display>():
                    return MetadataViews.Display(
                        name: "FlowtyWrapped #".concat(self.id.toString()),
                        description: "A celebration and statistical review of an exciting year on Flowty and across the Flow blockchain ecosystem.",
                        thumbnail: MetadataViews.HTTPFile(
                            url: self.image
                        )
                    )
                case Type<MetadataViews.Medias>():
                    let imageMedia = MetadataViews.Media(file: MetadataViews.HTTPFile(url: self.image), mediaType: "image/jpeg")
                    let htmlMedia = MetadataViews.Media(file: MetadataViews.HTTPFile(url: self.richHtml), mediaType: "text/html")
                    let mediasList: [MetadataViews.Media] = [imageMedia, htmlMedia]
                    return MetadataViews.Medias(
                        mediasList
                    )
                case Type<MetadataViews.Editions>():
                    let editionYear = MetadataViews.Edition(name: "Flowty Wrapped 2023", number: self.id, max: nil)
                    let editionList: [MetadataViews.Edition] = [editionYear]
                    return MetadataViews.Editions(
                        editionList
                    )
                case Type<MetadataViews.Serial>():
                    return MetadataViews.Serial(
                        self.id
                    )
                case Type<MetadataViews.Royalties>():
                    // note: Royalties are not aware of the token being used with, so the path is not useful right now
                    // eventually the FungibleTokenSwitchboard might be an option
                    // https://github.com/onflow/flow-ft/blob/master/contracts/FungibleTokenSwitchboard.cdc
                    let cut = MetadataViews.Royalty(
                        receiver: FlowtyWrapped.account.getCapability<&{FungibleToken.Receiver}>(/public/somePath),
                        cut: 0.050, // 5% royalty
                        description: "Creator Royalty"
                    )
                    var royalties: [MetadataViews.Royalty] = [cut]
                    return MetadataViews.Royalties(royalties)
                case Type<MetadataViews.ExternalURL>():
                    // TODO: Uncomment this with your own base url!
                    // return MetadataViews.ExternalURL("YOUR_BASE_URL/".concat(self.id.toString()))
                    return nil
                case Type<MetadataViews.NFTCollectionData>():
                    return FlowtyWrapped.resolveView(view)
                case Type<MetadataViews.NFTCollectionDisplay>():
                    return FlowtyWrapped.resolveView(view)
                case Type<MetadataViews.Traits>():
                    // let traitsView = MetadataViews.dictToTraits()
                    // return traitsView
                    return nil
            }
            return nil
        }
    }

    /// Defines the methods that are particular to this NFT contract collection
    ///
    pub resource interface FlowtyWrappedCollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowFlowtyWrapped(id: UInt64): &FlowtyWrapped.NFT? {
            post {
                (result == nil) || (result?.id == id):
                    "Cannot borrow FlowtyWrapped reference: the ID of the returned reference is incorrect"
            }
        }
    }

    /// The resource that will be holding the NFTs inside any account.
    /// In order to be able to manage NFTs any account will need to create
    /// an empty collection first
    ///
    pub resource Collection: FlowtyWrappedCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection {
        // dictionary of NFT conforming tokens
        // NFT is a resource type with an `UInt64` ID field
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        init () {
            self.ownedNFTs <- {}
        }

        /// Removes an NFT from the collection and moves it to the caller
        ///
        /// @param withdrawID: The ID of the NFT that wants to be withdrawn
        /// @return The NFT resource that has been taken out of the collection
        ///
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            // Panics on withdraw, this is not transferrable.
            assert(false, message: "Flowty Wrapped is not transferrable.")

            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")
            emit Withdraw(id: token.id, from: self.owner?.address)


            return <-token
        }

        /// Adds an NFT to the collections dictionary and adds the ID to the id array
        ///
        /// @param token: The NFT resource to be included in the collection
        /// 
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @FlowtyWrapped.NFT
            assert(token.ownerAddress == self.owner!.address, message: "The NFT must be owned by the Collection's owner")

            let id: UInt64 = token.id

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[id] <- token

            emit Deposit(id: id, to: self.owner?.address)

            destroy oldToken
        }

        /// Helper method for getting the collection IDs
        ///
        /// @return An array containing the IDs of the NFTs in the collection
        ///
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        /// Gets a reference to an NFT in the collection so that 
        /// the caller can read its metadata and call its methods
        ///
        /// @param id: The ID of the wanted NFT
        /// @return A reference to the wanted NFT resource
        ///
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
        }
 
        /// Gets a reference to an NFT in the collection so that 
        /// the caller can read its metadata and call its methods
        ///
        /// @param id: The ID of the wanted NFT
        /// @return A reference to the wanted NFT resource
        ///        
        pub fun borrowFlowtyWrapped(id: UInt64): &FlowtyWrapped.NFT? {
            if self.ownedNFTs[id] != nil {
                // Create an authorized reference to allow downcasting
                let ref = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
                return ref as! &FlowtyWrapped.NFT
            }

            return nil
        }

        /// Gets a reference to the NFT only conforming to the `{MetadataViews.Resolver}`
        /// interface so that the caller can retrieve the views that the NFT
        /// is implementing and resolve them
        ///
        /// @param id: The ID of the wanted NFT
        /// @return The resource reference conforming to the Resolver interface
        /// 
        pub fun borrowViewResolver(id: UInt64): &AnyResource{MetadataViews.Resolver} {
            let nft = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
            return nft as! &FlowtyWrapped.NFT
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }

    /// Allows anyone to create a new empty collection
    ///
    /// @return The new Collection resource
    ///
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }

    pub resource interface MinterPublic {
        pub fun mintNFT(ownerAddress: Address): @FlowtyWrapped.NFT
    }

    /// Resource that an admin or something similar would own to be
    /// able to mint new NFTs
    ///
    pub resource NFTMinter: MinterPublic {
        /// Mints a new NFT with a new ID and deposit it in the
        /// recipients collection using their collection reference
        ///
        /// @param recipient: A capability to the collection where the new NFT will be deposited
        ///
        pub fun mintNFT(ownerAddress: Address): @FlowtyWrapped.NFT {
            // we want IDs to start at 1, so we'll increment first
            FlowtyWrapped.totalSupply = FlowtyWrapped.totalSupply + 1

            // create a new NFT
            var newNFT <- create NFT(
                id: FlowtyWrapped.totalSupply,
                ownerAddress: ownerAddress
            )

            return <- newNFT

            // deposit it in the recipient's account using their reference
            // recipient.deposit(token: <-newNFT)
        }
    }

    /// Function that resolves a metadata view for this contract.
    ///
    /// @param view: The Type of the desired view.
    /// @return A structure representing the requested view.
    ///
    pub fun resolveView(_ view: Type): AnyStruct? {
        switch view {
            case Type<MetadataViews.NFTCollectionData>():
                return MetadataViews.NFTCollectionData(
                    storagePath: FlowtyWrapped.CollectionStoragePath,
                    publicPath: FlowtyWrapped.CollectionPublicPath,
                    providerPath: FlowtyWrapped.CollectionProviderPath,
                    publicCollection: Type<&FlowtyWrapped.Collection{FlowtyWrapped.FlowtyWrappedCollectionPublic}>(),
                    publicLinkedType: Type<&FlowtyWrapped.Collection{FlowtyWrapped.FlowtyWrappedCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(),
                    providerLinkedType: Type<&FlowtyWrapped.Collection{FlowtyWrapped.FlowtyWrappedCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Provider,MetadataViews.ResolverCollection}>(),
                    createEmptyCollectionFunction: (fun (): @NonFungibleToken.Collection {
                        return <-FlowtyWrapped.createEmptyCollection()
                    })
                )
            case Type<MetadataViews.NFTCollectionDisplay>():
                return MetadataViews.NFTCollectionDisplay(
                        name: "Flowty Wrapped",
                        description: "A celebration and statistical review of an exciting year on Flowty and across the Flow blockchain ecosystem.",
                        externalURL: MetadataViews.ExternalURL("https://flowty.io/"),
                        squareImage: MetadataViews.Media(
                            file: MetadataViews.HTTPFile(
                                url: "https://storage.googleapis.com/flowty-images/flowty-logo.jpeg"
                            ),
                            mediaType: "image/jpeg"
                        ),
                        bannerImage: MetadataViews.Media(
                            file: MetadataViews.HTTPFile(
                                url: "https://storage.googleapis.com/flowty-images/flowty-banner.jpeg"
                            ),
                            mediaType: "image/jpeg"
                        ),
                        socials: {
                            "twitter": MetadataViews.ExternalURL("https://twitter.com/flowty_io")
                        }
                    )
        }
        return nil
    }

    /// Function that returns all the Metadata Views implemented by a Non Fungible Token
    ///
    /// @return An array of Types defining the implemented views. This value will be used by
    ///         developers to know which parameter to pass to the resolveView() method.
    ///
    pub fun getViews(): [Type] {
        return [
            Type<MetadataViews.NFTCollectionData>(),
            Type<MetadataViews.NFTCollectionDisplay>()
        ]
    }

    pub fun borrowMinter(): &{MinterPublic} {
        return self.account.borrow<&{MinterPublic}>(from: self.MinterStoragePath)!
    }

    init() {
        // Initialize the total supply
        self.totalSupply = 0

        let identifier = "FlowtyWrapped_".concat(self.account.address.toString())

        // Set the named paths
        self.CollectionStoragePath = StoragePath(identifier: identifier)!
        self.CollectionPublicPath = PublicPath(identifier: identifier)!
        self.CollectionProviderPath = PrivatePath(identifier: identifier)!
        self.MinterStoragePath = StoragePath(identifier: identifier.concat("_Minter"))!
        self.MinterPublicPath = PublicPath(identifier: identifier.concat("_Minter"))!

        // Create a Collection resource and save it to storage
        let collection <- create Collection()
        self.account.save(<-collection, to: self.CollectionStoragePath)

        // create a public capability for the collection
        self.account.link<&FlowtyWrapped.Collection{NonFungibleToken.CollectionPublic, FlowtyWrapped.FlowtyWrappedCollectionPublic, MetadataViews.ResolverCollection}>(
            self.CollectionPublicPath,
            target: self.CollectionStoragePath 
        )

        // Create a Minter resource and save it to storage
        let minter <- create NFTMinter()
        self.account.save(<-minter, to: self.MinterStoragePath)

        emit ContractInitialized()
    }
}