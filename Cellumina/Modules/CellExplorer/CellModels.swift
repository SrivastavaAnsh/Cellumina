//
//  CellModels.swift
//  Cellumina
//
//  Created by Ansh Srivastava on 05/02/26.
//

import SwiftUI

// MARK: - Cell Types
enum ExplorerCellType: String, CaseIterable, Identifiable, Hashable {
    case animal, plant, bacteria
    var id: String {
        rawValue
    }

    var title: String {
        switch self {
            case .animal: return "Animal Cell"
            case .plant: return "Plant Cell"
            case .bacteria: return "Bacterial Cell"
        }
    }

    var subtitle: String {
        switch self {
            case .animal: return "Flexible membrane • Nucleus • Lysosomes"
            case .plant: return "Cell wall • Chloroplasts • Big vacuole"
            case .bacteria: return "No nucleus • Nucleoid • Small & fast"
        }
    }
}

extension ExplorerOrganelleID {
    var displayName: String {
        switch self {
            case .nucleus: return "Nucleus"
            case .nucleolus: return "Nucleolus"
            case .mitochondrion: return "Mitochondrion"
            case .ribosome: return "Ribosomes"
            case .golgi: return "Golgi Apparatus"
            case .er: return "Endoplasmic Reticulum (ER)"
            case .lysosome: return "Lysosome"
            case .chloroplast: return "Chloroplast"
            case .vacuole: return "Central Vacuole"
            case .cellWall: return "Cell Wall"
            case .nucleoid: return "Nucleoid"
            case .plasmid: return "Plasmid"
            case .flagellum: return "Flagellum"
            case .pili: return "Pili (Fimbriae)"
        }
    }
}

extension ExplorerCellType {
    var uiAccent: Color { tint }
    var aiOrganelles: [ExplorerOrganelleID] {
        switch self {
            case .animal:
                return [.nucleus, .nucleolus, .mitochondrion, .ribosome, .er, .golgi, .lysosome]
            case .plant:
                return [.cellWall, .nucleus, .nucleolus, .chloroplast, .vacuole, .mitochondrion, .ribosome, .er, .golgi]
            case .bacteria:
                return [.cellWall, .ribosome, .nucleoid, .plasmid, .flagellum, .pili]
        }
    }
}

// MARK: - Segments
enum ExplorerInfoSegment: String, CaseIterable, Identifiable {
    case overview = "Overview"
    case inside = "Inside"
    case facts = "Facts"
    var id: String {
        rawValue
    }
}

// MARK: - Organelle IDs
enum ExplorerOrganelleID: String, Identifiable, Hashable {
    case nucleus, nucleolus
    case mitochondrion, ribosome, golgi, er, lysosome
    case chloroplast, vacuole, cellWall
    case nucleoid, plasmid, flagellum, pili

    var id: String {
        rawValue
    }
}

extension ExplorerOrganelleID {
    func animationColor(for cell: ExplorerCellType) -> Color {
        switch self {

        case .nucleolus:
            return .red

        case .nucleus:
            return .red.opacity(0.75)

        case .mitochondrion:
            return .orange

        case .ribosome:
            return .purple

        case .er:
            return .indigo

        case .golgi:
            return .mint

        case .lysosome:
            return .yellow

        case .chloroplast:
            return .green.opacity(0.60)

        case .vacuole:
            return .cyan

        case .cellWall:
            switch cell {
            case .plant:
                return .green
            case .bacteria:
                return .orange
            case .animal:
                return .green
            }

        case .nucleoid:
            return .red

        case .plasmid:
            return .green

        case .flagellum:
            return .brown

        case .pili:
            return .orange
        }
    }
}

struct ExplorerOrganelle: Identifiable, Hashable {
    let id: ExplorerOrganelleID
    let name: String
    let oneLiner: String

    let overview: String
    let structure: String
    let location: String
    let keyFunctions: [String]
    let interactions: [String]
    let regulationAndControl: [String]
    let clinicalRelevance: [String]

    let onlyIn: Set<ExplorerCellType>

    static func catalog() -> [ExplorerOrganelle] {
        [
            // MARK: - nucleus
            .init(
                id: .nucleus,
                name: "Nucleus",
                oneLiner: "DNA vault & command center.",
                overview: """
                    Key: Defining organelle of eukaryotes (animals & plants).
                    Stores most DNA and controls cell behavior by regulating gene expression.
                """,
                structure: """
                    • Nuclear envelope: double membrane boundary
                    • Nuclear pores (NPCs): selective transport gates
                    • Nuclear lamina: support mesh (lamins)
                    • Chromatin: DNA & histones
                        – Euchromatin: open/active
                        – Heterochromatin: condensed/silent
                """,
                location: """
                    • Often near center in animal cells
                    • In plants, can be pushed to edge by the big vacuole
                """,
                keyFunctions: [
                    " Stores DNA & protects genome",
                    " Controls transcription (gene expression)",
                    " Coordinates replication & DNA repair",
                    " Controls cell cycle decisions via checkpoints"
                ],
                interactions: [
                    "Exports mRNA → ribosomes for translation",
                    "Nucleolus inside nucleus builds ribosome subunits",
                    "Receives signals (hormones/growth factors) via transcription factors"
                ],
                regulationAndControl: [
                    "Epigenetics (methylation/histones) controls gene access",
                    "Transcription factors speed up/slow down genes",
                    "Nuclear pores are gated, not open holes"
                ],
                clinicalRelevance: [
                    "Cancer: DNA repair/checkpoint failure → mutation buildup",
                    "Lamin defects → abnormal nuclear shape (laminopathies)",
                    "Viruses often hijack nuclear import/export"
                ],

                onlyIn: [.animal, .plant]
            ),

            // MARK: - nucleolus
            .init(
                id: .nucleolus,
                name: "Nucleolus",
                oneLiner: "rRNA & ribosome subunit factory.",
                overview: """
                    Key: Dense region inside nucleus where ribosome production starts.
                    Makes rRNA and assembles small & large ribosomal subunits.
                """,
                structure: """
                    • No membrane (phase-separated region)
                    • Forms around rRNA gene clusters (NORs)
                    • Packed with rRNA transcripts & processing proteins
                """,
                location: "Inside nucleus; bigger in cells that make lots of protein.",
                keyFunctions: [
                    " rRNA synthesis",
                    " Ribosome subunit assembly",
                    " Stress response hub (changes under stress)"
                ],
                interactions: [
                    "Imports ribosomal proteins from cytoplasm",
                    "Exports ribosomal subunits via nuclear pores"
                ],
                regulationAndControl: [
                    "Growth signals ↑ nucleolus activity",
                    "Cell stress ↓ rRNA synthesis (nucleolus shrinks/disrupts)"
                ],
                clinicalRelevance: [
                    "Cancer cells often show enlarged nucleoli (high protein demand)",
                    "Defects in ribosome biogenesis can cause disorders"
                ],

                onlyIn: [.animal, .plant]
            ),

            // MARK: - mitochondrion
            .init(
                id: .mitochondrion,
                name: "Mitochondrion",
                oneLiner: "ATP powerhouse & metabolism hub.",
                overview: """
                    Key: Makes most ATP via aerobic respiration.
                    Also involved in metabolism, apoptosis, signaling, and ROS handling.
                """,
                structure: """
                    • Outer membrane: permeable (porins)
                    • Inner membrane: folded cristae (↑ surface area)
                    • Intermembrane space: proton storage
                    • Matrix: Krebs enzymes & mtDNA & ribosomes
                """,
                location: "Cytoplasm; more in high-energy zones (muscle, neurons).",
                keyFunctions: [
                    " ATP production (oxidative phosphorylation)",
                    " Apoptosis control (cytochrome c release)",
                    " Calcium buffering & signaling"
                ],
                interactions: [
                    "Glycolysis feeds mitochondria (cytoplasm → mito)",
                    "Many proteins are nuclear-encoded (nucleus → mito)",
                    "Contacts ER for Ca²⁺ & lipid exchange"
                ],
                regulationAndControl: [
                    "Fission/fusion changes shape & performance",
                    "Biogenesis increases with energy demand",
                    "Membrane potential tightly regulated"
                ],

                clinicalRelevance: [
                    "Mito diseases hit brain/muscle first (high ATP demand)",
                    "Excess ROS linked to aging & degeneration"
                ],

                onlyIn: [.animal, .plant]
            ),

            // MARK: - ribosome
            .init(
                id: .ribosome,
                name: "Ribosomes",
                oneLiner: "Protein builders (translation).",
                overview: """
                    Key: Universal protein - making machines (all cells).
                    Reads mRNA codons, matches tRNA, builds polypeptides.
                """,
                structure: """
                    • It has two subunits (large & small)
                    • Made of rRNA + ribosomal proteins
                    • Sizes (sedimentation units, “S”):
                        – Prokaryote: 70S (50S + 30S)
                        – Eukaryote: 80S (60S + 40S)
                """,
                location: """
                    • Free: cytosolic proteins
                    • Rough ER-bound: secreted/membrane/lysosomal proteins
                    • Bacteria: cytoplasm (no ER)
                """,
                keyFunctions: [
                    " Protein synthesis (translation)",
                    " Protein routing (free vs RER-bound)"
                ],
                interactions: [
                    "Reads mRNA (nucleus in euk; nucleoid in bacteria)",
                    "Uses tRNA & amino acids from cytosol",
                    "RER docking routes secreted/membrane proteins"
                ],
                regulationAndControl: [
                    "Initiation factors control translation rate",
                    "Stress can slow translation temporarily"
                ],

                clinicalRelevance: [
                    "Many antibiotics target bacterial ribosomes"
                ],

                onlyIn: [.animal, .plant, .bacteria]
            ),

            // MARK: - golgi body
            .init(
                id: .golgi,
                name: "Golgi Apparatus",
                oneLiner: "Modify, sort, ship.",
                overview: """
                    Key: Cell’s logistics center.
                    Edits proteins/lipids from ER and packs them into vesicles for delivery.
                """,
                structure: """
                    • Stacked cisternae (“pancakes”)
                    • Cis face: receiving (from ER)
                    • Trans face: shipping (to membrane, secretion, lysosome)
                    • Trans-Golgi network: major sorting zone
                """,
                location: "Near ER & nucleus for fast trafficking.",
                keyFunctions: [
                    " Protein/lipid modification",
                    " Sorting & packaging",
                    " Targets enzymes to lysosomes",
                    " Supports secretion & membrane renewal"
                ],
                interactions: [
                    "Receives vesicles from ER",
                    "Sends vesicles to membrane / lysosomes / secretory vesicles"
                ],
                regulationAndControl: [
                    "Cargo tags decide destination",
                    "Budding/fusion is tightly controlled (SNARE idea)"
                ],
                clinicalRelevance: [
                    "Misrouting enzymes → storage disorders",
                    "Some pathogens hijack Golgi traffic"
                ],

                onlyIn: [.animal, .plant]
            ),

            // MARK: - ER
            .init(
                id: .er,
                name: "Endoplasmic Reticulum (ER)",
                oneLiner: "Protein & lipid manufacturing network.",
                overview: """
                    Key: Membrane network connected to nuclear envelope.
                    Rough ER = proteins; Smooth ER = lipids/detox/Ca²⁺.
                """,
                structure: """
                    • Rough ER: ribosome-studded sheets
                    • Smooth ER: tubular network, no ribosomes
                    • Lumen: folding/processing space
                """,
                location: "Continuous with nuclear envelope; spreads through cytoplasm.",
                keyFunctions: [
                    " RER: secreted & membrane proteins",
                    " SER: lipids & detox & Ca²⁺ storage",
                    " Quality control for folding"
                ],
                interactions: [
                    "Sends vesicles to Golgi",
                    "Contacts mitochondria for Ca²⁺ & lipids"
                ],
                regulationAndControl: [
                    "UPR responds to misfolded proteins",
                    "Chaperones assist folding; bad proteins degraded"
                ],

                clinicalRelevance: [
                    "ER stress linked to diabetes & neurodegeneration & inflammation",
                    "Drug metabolism depends on smooth ER capacity"
                ],

                onlyIn: [.animal, .plant]
            ),

            // MARK: - lysosome
            .init(
                id: .lysosome,
                name: "Lysosome",
                oneLiner: "Digest, recycle & cleanup.",
                overview: """
                    Key: Acidic enzyme sacs that digest waste and old organelles.
                    Important for recycling, defense, and cell health.
                """,
                structure: """
                    • Single membrane
                    • Acidic pH ~4.55 (proton pumps)
                    • Hydrolytic enzymes (proteases, lipases, nucleases)
                """,
                location: "Cytoplasm; fuses with endosomes/autophagosomes.",
                
                keyFunctions: [
                    " Digestion of macromolecules",
                    " Autophagy (recycling old organelles)",
                    " Defense vs pathogens"
                ],
                interactions: [
                    "Enzymes delivered via ER → Golgi",
                    "Fuses with endosomes & autophagosomes"
                ],
                regulationAndControl: [
                    "Acidic pH is essential for enzymes",
                    "Autophagy increases under starvation/stress"
                ],
                clinicalRelevance: [
                    "Storage diseases when enzymes are missing → buildup",
                    "Autophagy problems linked to neurodegeneration"
                ],

                onlyIn: [.animal]
            ),

            // MARK: - chloroplast
            .init(
                id: .chloroplast,
                name: "Chloroplast",
                oneLiner: "Photosynthesis engine.",
                overview: """
                    Key: Converts light energy into chemical energy.
                    Makes ATP/NADPH and builds sugars; releases O₂ as a byproduct.
                """,
                structure: """
                    • Double membrane
                    • Thylakoids (stacked = grana): light reactions
                    • Stroma: Calvin cycle enzymes
                    • Chlorophyll in thylakoid membranes
                    • Own DNA & ribosomes (endosymbiosis evidence)
                """,
                location: "Plant cytoplasm; can reposition to optimize light capture.",
                keyFunctions: [
                    " Photosynthesis (energy capture)",
                    " Oxygen generation",
                    " Sugar production (ecosystem base)"
                ],
                interactions: [
                    "Plants still use mitochondria for respiration",
                    "Exports sugars/metabolites to cytoplasm"
                ],
                regulationAndControl: [
                    "Rate depends on light, CO₂, temperature, water",
                    "Stomata control CO₂ access"
                ],
                clinicalRelevance: [
                    "Efficiency impacts crop yield & food security"
                ],

                onlyIn: [.plant]
            ),

            // MARK: - vacuole
            .init(
                id: .vacuole,
                name: "Central Vacuole",
                oneLiner: "Storage & pressure (turgor).",
                overview: """
                Key: Large plant compartment for water/solutes.
                    Maintains turgor pressure (why plants stay upright).
                """,
                structure: """
                    • Tonoplast: vacuole membrane
                    • Cell sap: water & ions & solutes
                    • Often fills most of plant cell volume
                """,
                location: "Central; pushes organelles toward edges.",
                keyFunctions: [
                    " Turgor pressure (rigidity)",
                    " Water/ion storage & pH control",
                    " Waste/pigment storage"
                ],
                interactions: [
                    "Works with cell wall for mechanical support",
                    "Tonoplast transport maintains homeostasis"
                ],
                regulationAndControl: [
                    "Ion gradients control filling",
                    "Drought/salt stress alters solute handling"
                ],
                clinicalRelevance: [
                    "Wilting = loss of turgor (water loss from vacuole)"
                ],

                onlyIn: [.plant]
            ),

            // MARK: - cell wall
            .init(
                id: .cellWall,
                name: "Cell Wall",
                oneLiner: "Rigid support & protection.",
                overview: """
                    Key: Provides shape and prevents bursting.
                    Plants: cellulose; bacteria: peptidoglycan (major antibiotic target).
                """,
                structure: """
                    Plant wall:
                    • Cellulose & hemicellulose & pectin
                    • Primary (flexible) vs secondary (strong)

                    Bacterial wall:
                    • Peptidoglycan mesh
                    • Gram+ vs Gram− differ in layers
                """,
                location: "Outside the plasma membrane.",
                keyFunctions: [
                    " Structural support & shape",
                    " Protection from osmotic/mechanical stress",
                    " Barrier interface with environment"
                ],
                interactions: [
                    "Plants: works with vacuole turgor pressure",
                    "Bacteria: supports membrane stability"
                ],
                regulationAndControl: [
                    "Plant wall remodeling enables growth",
                    "Bacterial synthesis regulated during division"
                ],
                clinicalRelevance: [
                    "Beta-lactams disrupt peptidoglycan synthesis",
                    "Wall integrity influences bacterial survival/virulence"
                ],

                onlyIn: [.plant, .bacteria]
            ),

            // MARK: - nucleoid
            .init(
                id: .nucleoid,
                name: "Nucleoid",
                oneLiner: "Bacterial DNA zone (no nucleus).",
                overview: """
                    Key: Bacteria lack a membrane-bound nucleus.
                    Main chromosome sits in nucleoid: packed but accessible DNA region.
                """,
                structure: """
                    • Usually one circular chromosome
                    • Supercoiled DNA & binding proteins
                    • No membrane boundary
                """,
                location: "Central-ish bacterial cytoplasm.",
                keyFunctions: [
                    " Stores bacterial chromosome",
                    " Enables fast replication & transcription"
                ],
                interactions: [
                    "Coupled with ribosomes (fast protein production)",
                    "Works alongside plasmids for extra traits"
                ],
                regulationAndControl: [
                    "Supercoiling affects gene accessibility",
                    "DNA-binding proteins organize regions"
                ],
                clinicalRelevance: [
                    "Replication/transcription machinery are antibiotic targets"
                ],
                                    
                onlyIn: [.bacteria]
            ),

            // MARK: - plasmid
            .init(
                id: .plasmid,
                name: "Plasmid",
                oneLiner: "Extra DNA rings (bonus traits).",
                overview: """
                    Key: Small circular DNA separate from chromosome.
                    Often carries antibiotic resistance, virulence, or metabolism genes.
                """,
                structure: """
                    • Circular DNA
                    • Own origin of replication
                    • Some are conjugative (transferable)
                """,
                location: "Bacterial cytoplasm.",
                keyFunctions: [
                    " Adds survival advantages",
                    " Enables rapid adaptation"
                ],
                interactions: [
                    "Transferred via conjugation (often pili)",
                    "Affects cell traits via gene expression"
                ],
                regulationAndControl: [
                    "Copy number control (high vs low copy)",
                    "Selection pressure keeps plasmids around"
                ],
                clinicalRelevance: [
                    "Major driver of antibiotic resistance spread",
                    "Can carry toxin/virulence genes"
                ],

                onlyIn: [.bacteria]
            ),

            // MARK: - flagellum
            .init(
                id: .flagellum,
                name: "Flagellum",
                oneLiner: "Rotating motor for movement.",
                overview: """
                    Key: Bacterial flagella rotate like propellers (not whipping).
                    Helps chemotaxis: move toward nutrients, away from toxins.
                """,
                structure: """
                    • Filament: flagellin tail
                    • Hook: connector
                    • Basal body: rotary motor in envelope
                    • Powered by ion gradient (often proton motive force)
                """,
                location: """
                    Anchored in cell envelope.
                """,
                keyFunctions: [
                    " Motility",
                    " Chemotaxis navigation",
                    " Supports colonization (sometimes infection)"
                ],
                interactions: [
                    "Chemotaxis receptors/signals control motor behavior",
                    "Can work with pili during colonization/biofilm stages"
                ],
                regulationAndControl: [
                    "Direction/speed controlled by chemotaxis signaling",
                    "Synthesis depends on environment & energy"
                ],
                clinicalRelevance: [
                    "Flagellin triggers immune response",
                    "Motility can increase virulence"
                ],

                onlyIn: [.bacteria]
            ),

            // MARK: - Pili
            .init(
                id: .pili,
                name: "Pili (Fimbriae)",
                oneLiner: "Attachment & DNA transfer.",
                overview: """
                    Key: Surface filaments for adhesion, biofilms, and conjugation.
                    Major reason bacteria stick to tissues and devices.
                """,
                structure: """
                    • Pilin filaments
                    • Short fimbriae: adhesion
                    • Long sex pili: conjugation bridge
                    • Some retract (twitching movement)
                """,
                location: "Bacterial surface.",
                keyFunctions: [
                    " Surface attachment",
                    " Biofilm formation",
                    " Conjugation (gene transfer)",
                    " Twitching motility (some bacteria)"
                ],
                interactions: [
                    "Transfers plasmids (often resistance genes)",
                    "Biofilms interact with capsules/extracellular matrix"
                ],
                regulationAndControl: [
                    "Expression changes with environment (host/surfaces/stress)",
                    "Biofilm programs are coordinated"
                ],
                clinicalRelevance: [
                    "Biofilms are harder to kill (antibiotics & immune system struggle)",
                    "Adhesion contributes to UTIs and device infections"
                ],
                
                onlyIn: [.bacteria]
            ),
        ]
    }
}




extension ExplorerCellType {

    var longDescription: String {
        switch self {
        case .animal:
            return """
• Flexible, highly specialized eukaryotic cell built for movement, signaling, and complex tissue roles.
• Specialize heavily (neurons vs muscle vs immune) for division of labor.
"""
        case .plant:
            return """
• Rigid, energy-producing eukaryotic cell powered by sunlight and structural support.
• Turgor pressure keeps plant cell rigid and upright.
"""
        case .bacteria:
            return """
• Minimalist prokaryotic cell engineered for speed, survival, and rapid adaptation.
• Rapid division and fast adaptation (mutation & gene transfer).
"""
        }
    }

    var whatItIs: String {
        switch self {
        case .animal:
            return """
• Eukaryotic cell with nucleus & membrane organelles.
• Flexible shape helps movement, signaling, and specialized tissue roles.
"""
        case .plant:
            return """
• Eukaryotic cell with nucleus and organelles
• cell wall (support), chloroplasts (photosynthesis), big vacuole (turgor & storage).
"""
        case .bacteria:
            return """
• Prokaryotic cell with no nucleus or membrane organelles.
• DNA in nucleoid; plasmids can add resistance/virulence traits.
"""
        }
    }

    var whatItDoes: String {
        switch self {
        case .animal:
            return """
• Makes ATP, proteins, and runs signaling for tissue coordination.
• Supports growth/repair and immune defense; flexible membrane enables movement.
"""
        case .plant:
            return """
• Makes sugars using sunlight (photosynthesis) and stores water/solutes.
• Builds structural support (cell wall) and stays rigid via turgor pressure.
"""
        case .bacteria:
            return """
• Takes nutrients → energy → divides fast (binary fission).
• Adapts via mutation & plasmids; can move (flagella) and attach (pili/biofilms).
"""
        }
    }

    var keySystems: [String] {
        switch self {
        case .animal:
            return [
                " Membrane: transport and signaling",
                " Nucleus: DNA control",
                " Mitochondria: ATP and metabolism",
                " ER/Golgi: build and ship proteins/lipids",
                " Lysosomes: recycling and cleanup"
            ]
        case .plant:
            return [
                " Cell wall: structure and protection",
                " Chloroplasts: photosynthesis",
                " Central vacuole: storage and turgor",
                " Mitochondria: respiration"
            ]
        case .bacteria:
            return [
                " Cell wall/membrane: protection and transport",
                " Nucleoid: main DNA",
                " Ribosomes (70S): protein synthesis",
                " Plasmids: extra traits",
                " Flagella/pili: motility, attachment and gene transfer"
            ]
        }
    }

    var funFacts: [String] {
        switch self {
        case .animal:
            return [
                " Neurons can last your entire lifetime without dividing.",
                " Some immune cells can change shape dramatically to squeeze through tissues.",
                " Human skin cells fully replace themselves roughly every 3–4 weeks.",
                " Cancer cells often reactivate division pathways that normal adult cells keep shut down.",
                " Some animal cells (like muscle fibers) are multinucleated."
            ]

        case .plant:
            return [
                " Chloroplasts have their own DNA.",
                " A single large central vacuole can take up 80–90% of the cell’s volume.",
                " Plant cells can communicate through tiny channels called plasmodesmata.",
                " The rigidity of plants comes more from water pressure than from solid tissue.",
                " Chloroplasts likely evolved from ancient photosynthetic bacteria."
            ]

        case .bacteria:
            return [
                " Some bacteria divide in ~20 minutes (ideal conditions).",
                " Biofilms make bacteria much harder to kill with antibiotics.",
                " Some bacteria survive extreme heat, radiation, or even space exposure.",
                " Not all bacteria are harmful — many are essential for digestion and immunity.",
                " Antibiotic resistance often spreads through plasmids."
            ]
        }
    }

    var shortTitle: String {
        switch self {
        case .animal: return "Animal"
        case .plant: return "Plant"
        case .bacteria: return "Bacteria"
        }
    }

    var quickLine: String {
        switch self {
        case .animal: return "Flexible membrane • Nucleus"
        case .plant: return "Cell wall • Chloroplasts"
        case .bacteria: return "No nucleus • Small & Fast"
        }
    }

    var tint: Color {
        switch self {
        case .animal: return .pink
        case .plant: return .green
        case .bacteria: return .orange
        }
    }

    var icon: String {
        switch self {
        case .animal: return "circle.grid.cross.fill"
        case .plant: return "leaf.fill"
        case .bacteria: return "bubbles.and.sparkles.fill"
        }
    }
}

