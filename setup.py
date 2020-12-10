from importlib import reload
from setuptools import setup, find_packages
from setuptools.command.install import install
from shutil import copyfile
import platform, sys

class InstallJulia(install):
    def run(self):
        install.run(self)
        if platform.system() == "Linux":
            ext = "so"
        elif platform.system() == "Darwin":
            ext = "dylib"
        elif platform.system() == "Windows":
            ext = "dll"
        else:
            raise ValueError("Can't install on system " + platform.system())
        sysimage_path = self.install_lib + "CriticalDifferenceDiagrams_jl/sys." + ext
        script_path = self.install_lib + "CriticalDifferenceDiagrams_jl/precompile.jl"
        print("Installing Julia: about to generate " + sysimage_path)

        print("Installing Julia (step 1/5): basic installation")
        import julia
        julia.install()

        print("Installing Julia (step 2/5): reloading")
        reload(julia) # reload required
        from julia.api import Julia
        jl = Julia(compiled_modules=False)
        from julia import Main

        print("Installing Julia (step 3/5): adding packages")
        Main.eval("""
            using Pkg
            Pkg.activate(".")
            Pkg.add(["CriticalDifferenceDiagrams", "CSV", "DataFrames", "PackageCompiler", "Pandas", "PyCall"])
        """)

        print("Installing Julia (step 4/5): building PyCall.jl")
        Main.eval("ENV[\"PYTHON\"] = \"" + sys.executable + "\"; Pkg.build(\"PyCall\")")

        print("Installing Julia (step 5/5): building the sysimage")
        from julia.sysimage import build_sysimage
        build_sysimage(sysimage_path, script=script_path, compiler_env=".")

with open('README.md') as f:
    readme = f.read()
with open('LICENSE.md') as f:
    license = f.read()

setup(
    name='CriticalDifferenceDiagrams_jl',
    version='0.0.1',
    description='Python wrapper for plotting critical difference diagrams with Julia',
    long_description=readme,
    author='Mirko Bunse',
    author_email='mirko.bunse@cs.tu-dortmund.de',
    url='https://github.com/mirkobunse/CriticalDifferenceDiagrams.jl',
    license=license,
    packages=find_packages(exclude=('tests', 'docs')),
    tests_require=['pytest'],
    setup_requires=['pytest-runner'],
    package_data={"": ["*.jl"]},
    install_requires=[
        'julia >= 0.5.6',
        'pandas >= 1.1.4'
    ],
    classifiers=[
        'Development Status :: 4 - Beta',
        'Intended Audience :: Science/Research',
        'License :: OSI Approved :: GNU General Public License v3 (GPLv3)',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'Programming Language :: Python :: 3 :: Only',
        'Topic :: Scientific/Engineering',
        'Topic :: Scientific/Engineering :: Artificial Intelligence',
        'Topic :: Scientific/Engineering :: Machine Learning'
    ],
    cmdclass={'install': InstallJulia}
)
