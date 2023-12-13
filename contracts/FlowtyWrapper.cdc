import "NonFungibleToken"
import "MetadataViews"
import "ViewResolver"
import "FungibleToken"

access(all) contract FlowtyWrapper: NonFungibleToken, ViewResolver {

    // Total supply of FlowtyWrappers
    access(all) var totalSupply: UInt64

    /// The event that is emitted when the contract is created
    access(all) event ContractInitialized()

    /// The event that is emitted when an NFT is withdrawn from a Collection
    access(all) event Withdraw(id: UInt64, from: Address?)

    /// The event that is emitted when an NFT is deposited to a Collection
    access(all) event Deposit(id: UInt64, to: Address?)

    /// Storage and Public Paths
    access(all) let CollectionStoragePath: StoragePath
    access(all) let CollectionPublicPath: PublicPath
    access(all) let CollectionProviderPath: PrivatePath
    access(all) let MinterStoragePath: StoragePath

    // We only have a public path for minting to let FlowtyWrappers be like a faucet.
    access(all) let MinterPublicPath: PublicPath

    /// The core resource that represents a Non Fungible Token. 
    /// New instances will be created using the NFTMinter resource
    /// and stored in the Collection resource
    ///
    access(all) resource NFT: NonFungibleToken.INFT, MetadataViews.Resolver {

        /// The unique ID that each NFT has
        access(all) let id: UInt64
        access(all) let image: String
        access(all) let richHtml: String
        access(all) let data: {String: AnyStruct} // any extra data like a name or mint time

        init(
            id: UInt64,
        ) {
            self.id = id
            self.image = "https://storage.googleapis.com/flowty-images/flowty-logo.jpeg"
            self.richHtml = ""
            self.data = {}

            // We will add some Raffle entry logic here, probably 
        }

        /// Function that returns all the Metadata Views implemented by a Non Fungible Token
        ///
        /// @return An array of Types defining the implemented views. This value will be used by
        ///         developers to know which parameter to pass to the resolveView() method.
        ///
        access(all) fun getViews(): [Type] {
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
        access(all) fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<MetadataViews.Display>():
                    return MetadataViews.Display(
                        name: "FlowtyWrapper #".concat(self.id.toString()),
                        description: "Flowty Wrapper contract description",
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
                    // There is no max number of NFTs that can be minted from this contract
                    // so the max edition field value is set to nil
                    let editionInfo = MetadataViews.Edition(name: "Flowty Wrapper", number: self.id, max: nil)
                    let editionList: [MetadataViews.Edition] = [editionInfo]
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
                        receiver: FlowtyWrapper.account.getCapability<&{FungibleToken.Receiver}>(/public/somePath),
                        cut: 0.025, // 2.5% royalty
                        description: "Creator Royalty"
                    )
                    var royalties: [MetadataViews.Royalty] = [cut]
                    return MetadataViews.Royalties(royalties)
                case Type<MetadataViews.ExternalURL>():
                    // TODO: Uncomment this with your own base url!
                    // return MetadataViews.ExternalURL("YOUR_BASE_URL/".concat(self.id.toString()))
                    return nil
                case Type<MetadataViews.NFTCollectionData>():
                    return FlowtyWrapper.resolveView(view)
                case Type<MetadataViews.NFTCollectionDisplay>():
                    return FlowtyWrapper.resolveView(view)
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
    access(all) resource interface FlowtyWrapperCollectionPublic {
        access(all) fun deposit(token: @NonFungibleToken.NFT)
        access(all) fun getIDs(): [UInt64]
        access(all) fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        access(all) fun borrowFlowtyWrapper(id: UInt64): &FlowtyWrapper.NFT? {
            post {
                (result == nil) || (result?.id == id):
                    "Cannot borrow FlowtyWrapper reference: the ID of the returned reference is incorrect"
            }
        }
    }

    /// The resource that will be holding the NFTs inside any account.
    /// In order to be able to manage NFTs any account will need to create
    /// an empty collection first
    ///
    access(all) resource Collection: FlowtyWrapperCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection {
        // dictionary of NFT conforming tokens
        // NFT is a resource type with an `UInt64` ID field
        access(all) var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        init () {
            self.ownedNFTs <- {}
        }

        /// Removes an NFT from the collection and moves it to the caller
        ///
        /// @param withdrawID: The ID of the NFT that wants to be withdrawn
        /// @return The NFT resource that has been taken out of the collection
        ///
        access(all) fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <-token
        }

        /// Adds an NFT to the collections dictionary and adds the ID to the id array
        ///
        /// @param token: The NFT resource to be included in the collection
        /// 
        access(all) fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @FlowtyWrapper.NFT

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
        access(all) fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        /// Gets a reference to an NFT in the collection so that 
        /// the caller can read its metadata and call its methods
        ///
        /// @param id: The ID of the wanted NFT
        /// @return A reference to the wanted NFT resource
        ///
        access(all) fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
        }
 
        /// Gets a reference to an NFT in the collection so that 
        /// the caller can read its metadata and call its methods
        ///
        /// @param id: The ID of the wanted NFT
        /// @return A reference to the wanted NFT resource
        ///        
        access(all) fun borrowFlowtyWrapper(id: UInt64): &FlowtyWrapper.NFT? {
            if self.ownedNFTs[id] != nil {
                // Create an authorized reference to allow downcasting
                let ref = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
                return ref as! &FlowtyWrapper.NFT
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
        access(all) fun borrowViewResolver(id: UInt64): &AnyResource{MetadataViews.Resolver} {
            let nft = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
            return nft as! &FlowtyWrapper.NFT
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }

    /// Allows anyone to create a new empty collection
    ///
    /// @return The new Collection resource
    ///
    access(all) fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }

    access(all) resource interface MinterPublic {
        access(all) fun mintNFT(): @FlowtyWrapper.NFT
    }

    /// Resource that an admin or something similar would own to be
    /// able to mint new NFTs
    ///
    access(all) resource NFTMinter: MinterPublic {
        /// Mints a new NFT with a new ID and deposit it in the
        /// recipients collection using their collection reference
        ///
        /// @param recipient: A capability to the collection where the new NFT will be deposited
        ///
        access(all) fun mintNFT(): @FlowtyWrapper.NFT {
            // we want IDs to start at 1, so we'll increment first
            FlowtyWrapper.totalSupply = FlowtyWrapper.totalSupply + 1

            // create a new NFT
            var newNFT <- create NFT(
                id: FlowtyWrapper.totalSupply,
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
    access(all) fun resolveView(_ view: Type): AnyStruct? {
        switch view {
            case Type<MetadataViews.NFTCollectionData>():
                return MetadataViews.NFTCollectionData(
                    storagePath: FlowtyWrapper.CollectionStoragePath,
                    publicPath: FlowtyWrapper.CollectionPublicPath,
                    providerPath: FlowtyWrapper.CollectionProviderPath,
                    publicCollection: Type<&FlowtyWrapper.Collection{FlowtyWrapper.FlowtyWrapperCollectionPublic}>(),
                    publicLinkedType: Type<&FlowtyWrapper.Collection{FlowtyWrapper.FlowtyWrapperCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(),
                    providerLinkedType: Type<&FlowtyWrapper.Collection{FlowtyWrapper.FlowtyWrapperCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Provider,MetadataViews.ResolverCollection}>(),
                    createEmptyCollectionFunction: (fun (): @NonFungibleToken.Collection {
                        return <-FlowtyWrapper.createEmptyCollection()
                    })
                )
            case Type<MetadataViews.NFTCollectionDisplay>():
                return MetadataViews.NFTCollectionDisplay(
                        name: "Flowty Wrapper",
                        description: "Flowty Wrapper Collection Description - TODO",
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
    access(all) fun getViews(): [Type] {
        return [
            Type<MetadataViews.NFTCollectionData>(),
            Type<MetadataViews.NFTCollectionDisplay>()
        ]
    }

    access(all) fun borrowMinter(): &{MinterPublic} {
        return self.account.borrow<&{MinterPublic}>(from: self.MinterStoragePath)!
    }

    init() {
        // Initialize the total supply
        self.totalSupply = 0

        let identifier = "FlowtyWrapper_".concat(self.account.address.toString())

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
        self.account.link<&FlowtyWrapper.Collection{NonFungibleToken.CollectionPublic, FlowtyWrapper.FlowtyWrapperCollectionPublic, MetadataViews.ResolverCollection}>(
            self.CollectionPublicPath,
            target: self.CollectionStoragePath 
        )

        // Create a Minter resource and save it to storage
        let minter <- create NFTMinter()
        self.account.save(<-minter, to: self.MinterStoragePath)

        emit ContractInitialized()
    }
}