$dirs = @(
    "data/raw",
    "data/processed",
    "baselines",
    "models",
    "evaluation",
    "results",
    "figures",
    "paper",
    "notebooks"
)

foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

$files = @(
    "README.md",
    "baselines/svm_baseline.py",
    "baselines/eegnet_baseline.py",
    "baselines/lstm_baseline.py",
    "models/proposed_model.py",
    "evaluation/loso_cv.py",
    "evaluation/metrics.py",
    "results/baseline_results.csv",
    "notebooks/exploration.ipynb",
    "data/raw/.gitkeep",
    "data/processed/.gitkeep",
    "figures/.gitkeep",
    "paper/.gitkeep"
)

foreach ($file in $files) {
    New-Item -ItemType File -Path $file -Force | Out-Null
}