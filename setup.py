from setuptools import setup, find_packages
from setuptools.command.install import install

class JuliaDependencies(install):
    def run(self):
        install.run(self)
        import julia
        julia.install()
        from julia import Pkg
        Pkg.add("CriticalDifferenceDiagrams")
        Pkg.add("Pandas")

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
    cmdclass={'install': JuliaDependencies}
)
