import UIKit

private let reuseIdentifier = "Cell"

private let items = [
    "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware",
    "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky",
    "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri",
    "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York",
    "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island",
    "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington",
    "West Virginia", "Wisconsin", "Wyoming"
]




class BasicCollectionViewController: UICollectionViewController {
    
    let searchController = UISearchController()
     
    //The keyword layzy instructs the compiler to delay initializing the filtered items array until the first time its needed (For performence)
    lazy var filteredItems: [String] = items
    
    var dataSource: UICollectionViewDiffableDataSource<Character, String>!
    
    func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Character, String>(collectionView: collectionView, cellProvider: { collectionView, indexPath, item ->
            UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as!
            BasicCollectionViewCell
            
            cell.label.text = item
            
            return cell
        })
        
        
        //This doesn't work
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView? in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! BasicHeaderView
            header.headerLabel.text = String(self.initialLetters[indexPath.section])
            
            return header
        }
        
        dataSource.apply(filteredItemSnapshot)
        
    }
    
    var filteredItemSnapshot: NSDiffableDataSourceSnapshot<Character, String> {
        var snapshot = NSDiffableDataSourceSnapshot<Character, String>()
        
        for section in initialLetters {
            snapshot.appendSections([section])
            snapshot.appendItems(itemsByInitialLetter[section]!, toSection: nil)
        }
        
        return snapshot
    }
    
    var itemsByInitialLetter: [Character: [String]] = [:]
    var initialLetters: [Character] = []
    
    func update() {
        if let searchString = searchController.searchBar.text,
           
            searchString.isEmpty == false {
            filteredItems = items.filter { (item) -> Bool in
                item.localizedStandardContains(searchString)
            }
        } else {
            filteredItems = items
        }
        
        //This is don't understand
        itemsByInitialLetter = filteredItems.reduce([:]) {
               existing, element in
                return existing.merging([element.first!: [element]]) { old,
                   new in
                    return old + new
                }
            }
        
            initialLetters = itemsByInitialLetter.keys.sorted()
        print(initialLetters)
        print(itemsByInitialLetter)
                
        dataSource.apply(filteredItemSnapshot, animatingDifferences: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.setCollectionViewLayout(generateLayout(), animated: false)
        navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        
        createDataSource()
        update()
        
    }

    private func generateLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let spacing: CGFloat = 10.0

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(70)
        )
         
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: 1
        )

        group.contentInsets = NSDirectionalEdgeInsets(
            top: spacing,
            leading: spacing,
            bottom: 0,
            trailing: spacing
        )

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        section.interGroupSpacing = 8

        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    // MARK: - UICollectionViewDataSource
    
    /*
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredItems.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BasicCollectionViewCell
    
        cell.label.text = filteredItems[indexPath.item]
    
        return cell
    }
     */

    // MARK: - UICollectionViewDelegate

    // TBD
    
    
}

extension BasicCollectionViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        update()
    }
    
}
