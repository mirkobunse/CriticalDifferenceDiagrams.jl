import CriticalDifferenceDiagrams_jl as cdd
import pandas as pd
from wget import download
from unittest import TestCase

class TestReadme(TestCase):
    def test_readme(self):
        download("https://raw.githubusercontent.com/hfawaz/cd-diagram/master/example.csv")
        df = pd.read_csv("example.csv")
        plot = cdd.plot(
            df,
            "classifier_name",
            "dataset_name",
            "accuracy",
            maximize_outcome = True,
            title = "CriticalDifferenceDiagrams.jl"
        )
        cdd.pushPGFPlotsPreamble("\\usepackage{lmodern}")
        cdd.save("example.tex", plot)
        with open("example.tex") as f:
            print(f.read())
