# scop Function Map

Use this file as a quick chooser before searching the full `scop` repo.

Baseline: aligned to `scop` `0.8.6`.

## Version-Sensitive Defaults

- Write new code with `group.by`, not `group_by`
- Expect plotting defaults to use palette `"Chinese"`
- Prefer `cores` for newer parallel interfaces such as `scVI_integrate()`, `RunNMF()`, `DynamicHeatmap()`, `FeatureHeatmap()`, `GroupHeatmap()`, and `RunDynamicEnrichment()`
- Do not use removed example datasets `ifnb_sub`, `ref_scHCL`, or `ref_scZCL`; prefer `pancreas_sub`, `panc8_sub`, and `ref_scMCA`

## Standard Workflow And Reduction

- Build a standard Seurat-based analysis pipeline -> `standard_scop()`
- Run a specific dimensional reduction workflow -> `RunDimReduction()`
- Run UMAP with `scop` wrapper -> `RunUMAP2()`
- Run PHATE -> `RunPHATE()`
- Run TriMap -> `RunTriMap()`
- Run PaCMAP -> `RunPaCMAP()`
- Run LargeVis -> `RunLargeVis()`
- Run diffusion map -> `RunDM()`
- Run force-directed layout -> `RunFR()`
- Run GLMPCA -> `RunGLMPCA()`
- Run NMF with thread control -> `RunNMF(cores = ...)`
- Run MDS -> `RunMDS()`
- Choose the default reduction for later plotting -> `DefaultReduction()`

## QC, Doublets, And Ambient RNA

- Run integrated cell QC -> `RunCellQC()`
- Include ambient RNA decontamination inside QC -> `RunCellQC(qc_metrics = c(..., "decontX", ...))`
- Filter on decontamination contamination during QC -> `RunCellQC(decontX_threshold = ..., decontX_store_assay = TRUE/FALSE)`
- Run standalone ambient RNA decontamination -> `RunDecontX()`
- Plot decontamination contamination score -> `FeatureStatPlot(stat.by = "decontX_contamination")` or `FeatureDimPlot(features = "decontX_contamination")`
- Run doublet calling with a chosen backend -> `RunDoubletCalling()`
- Call doublets with `scDblFinder` explicitly -> `db_scDblFinder()`
- Call doublets with `scds` explicitly -> `db_scds()`
- Call doublets with `Scrublet` explicitly -> `db_Scrublet()`
- Recover counts if needed after processing -> `RecoverCounts()`

## Annotation And Mapping

- Annotate with SingleR -> `RunSingleR()`
- Annotate with CellTypist -> `RunCellTypist()`
- List CellTypist models -> `CellTypistModels()`
- Annotate with scmap -> `RunScmap()`
- Predict labels with nearest-neighbor strategy -> `RunKNNPredict()`
- Map query cells to a reference dataset -> `RunKNNMap()`
- Map query cells with Seurat anchors -> `RunSeuratMap()`
- Map query cells with Symphony -> `RunSymphonyMap()`
- Map query cells with CSS -> `RunCSSMap()`
- Map query cells with PCA projection -> `RunPCAMap()`
- Visualize query-to-reference projection -> `ProjectionPlot()`
- Compare query and reference groups by correlation -> `CellCorHeatmap()`

## Integration

- Run the main integration workflow -> `integration_scop()`
- Use Seurat integration -> `Seurat_integrate()`
- Use Harmony integration -> `Harmony_integrate()` or `RunHarmony2()`
- Use scVI integration with current thread naming -> `scVI_integrate(cores = ...)`
- Use MNN or fastMNN -> `MNN_integrate()` or `fastMNN_integrate()`
- Use Scanorama -> `Scanorama_integrate()`
- Use BBKNN -> `BBKNN_integrate()`
- Use CSS -> `CSS_integrate()`
- Use LIGER -> `LIGER_integrate()`
- Use Conos -> `Conos_integrate()`
- Use ComBat -> `ComBat_integrate()`
- Keep data uncorrected but standardized -> `Uncorrected_integrate()`

## Trajectory And Cell Fate

- Estimate RNA velocity -> `RunSCVELO()`
- Plot velocity arrows or streams -> `VelocityPlot()`
- Build PAGA graph -> `RunPAGA()`
- Plot PAGA topology -> `PAGAPlot()`
- Run Slingshot lineage inference -> `RunSlingshot()`
- Run Monocle 2 trajectory analysis -> `RunMonocle2()`
- Run Monocle 3 trajectory analysis -> `RunMonocle3()`
- Add custom axis labels in Monocle plotting output -> `RunMonocle2(xlab = ..., ylab = ...)` or `RunMonocle3(xlab = ..., ylab = ...)`
- Run Palantir -> `RunPalantir()`
- Run CellRank -> `RunCellRank()`
- Run WOT -> `RunWOT()`
- Plot lineage-level summaries -> `LineagePlot()`
- Predict differentiation potency -> `RunCytoTRACE()`
- Plot CytoTRACE results -> `CytoTRACEPlot()`
- Identify dynamic features with GAM -> `RunDynamicFeatures(fit_method = "gam")`
- Identify dynamic features with PreTSA -> `RunDynamicFeatures(fit_method = "pretsa", knot = 0 or "auto", max_knot_allowed = ...)`
- Plot dynamic curves -> `DynamicPlot()`
- Plot dynamic heatmap -> `DynamicHeatmap()`

## Differential Expression And Feature Dynamics

- Run differential expression testing -> `RunDEtest()`
- Find expressed markers -> `FindExpressedMarkers()`
- Plot DE volcano, Manhattan, or ring views -> `DEtestPlot(plot_type = "volcano" | "manhattan" | "ring")`
- Plot a user-supplied DE table without rerunning tests -> `DEtestPlot(res = ...)`
- Use standalone Manhattan or ring helpers if needed -> `DEtestManhattanPlot()`, `DEtestRingPlot()`
- Run cell proportion testing -> `RunProportionTest()`
- Plot proportion results -> `ProportionTestPlot()`
- Annotate feature sets such as TF or surface proteins -> `AnnotateFeatures()`

## Enrichment, Scoring, And Metabolism

- Run over-representation enrichment -> `RunEnrichment()`
- Plot enrichment summaries -> `EnrichmentPlot()`
- Run GSEA -> `RunGSEA()`
- Plot GSEA results -> `GSEAPlot()`
- Run GSVA for general pathway scoring -> `RunGSVA()`
- Plot GSVA results -> `GSVAPlot()`
- Use group-level GSVA -> `RunGSVA(group.by = "...")`
- Use single-cell GSVA with a new assay -> `RunGSVA(group.by = NULL, new_assay = TRUE)`
- Run metabolism pathway scoring -> `RunMetabolism(method = "AUCell" | "GSVA" | "ssGSEA" | "VISION")`
- Use group-level metabolism scoring -> `RunMetabolism(group.by = "...")`
- Plot metabolism results -> `MetabolismPlot()`
- Run dynamic enrichment on trajectories -> `RunDynamicEnrichment()`
- Run signature-style cell scoring -> `CellScoring()`

## Cell-Cell Communication

- Run CellChat analysis -> `RunCellChat()`
- Plot CellChat results -> `CellChatPlot()`

## Common Visualization

- Plot cells on embedding -> `CellDimPlot()`
- Plot cells on embedding in 3D -> `CellDimPlot3D()`
- Plot gene expression on embedding -> `FeatureDimPlot()`
- Plot gene expression on embedding in 3D -> `FeatureDimPlot3D()`
- Override legend titles in common plots -> `legend.title = ...` in `CellDimPlot()`, `FeatureDimPlot()`, `FeatureStatPlot()`, and `ExpressionStatPlot()`
- Plot grouped heatmaps -> `GroupHeatmap()`
- Plot selected feature heatmaps -> `FeatureHeatmap()`
- Use multi-core heatmap rendering where supported -> `DynamicHeatmap(cores = ...)`, `FeatureHeatmap(cores = ...)`, `GroupHeatmap(cores = ...)`
- Plot cell density -> `CellDensityPlot()`
- Plot metadata or QC summaries -> `CellStatPlot()`
- Plot expression statistics across groups -> `FeatureStatPlot()`, `ExpressionStatPlot()`
- Plot feature correlations -> `FeatureCorPlot()`
- Plot graph structures -> `GraphPlot()`

## Databases, Environments, And SCExplorer

- Prepare annotation databases -> `PrepareDB()`
- List cached databases for one or more species -> `ListDB(species = c("Homo_sapiens", "Mus_musculus"))`
- Prepare Python environment for `scop` methods -> `PrepareEnv(version = ...)`
- Prepare files for SCExplorer -> `PrepareSCExplorer()`, `CreateDataFile()`, `CreateMetaFile()`
- Read back SCExplorer HDF5 content -> `FetchH5()`
- Launch SCExplorer -> `RunSCExplorer()`

## Practical Defaults

- Clustering plus UMAP request -> `standard_scop()` then `CellDimPlot()`
- QC overview request -> `RunCellQC()` then `CellStatPlot()` and `CellDimPlot()`
- QC request with ambient RNA concern -> `RunCellQC()` with `"decontX"` in `qc_metrics`, or `RunDecontX()` if the user wants the step isolated
- Marker plus enrichment request -> `RunDEtest()` then `RunEnrichment()` and `EnrichmentPlot()`
- Existing DE table from the user -> `DEtestPlot(res = ...)`
- Gene-set scoring request -> `RunGSVA()` then `GSVAPlot()`
- Metabolism request -> `RunMetabolism()` then `MetabolismPlot()`
- UMAP feature expression request -> `FeatureDimPlot()`
- Reference annotation request -> `RunSingleR()` or `RunCellTypist()` depending on the reference source
- Trajectory request with velocity assays present -> `RunSCVELO()` and optionally `RunPAGA()`
- Trajectory request focused on pseudotime trends -> `RunSlingshot()` or `RunMonocle3()` then `RunDynamicFeatures()`
