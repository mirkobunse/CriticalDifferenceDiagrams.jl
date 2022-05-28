from setuptools import setup, find_packages

def readme():
    with open('README.md') as f:
        return f.read()
def licence():
    with open('LICENSE.md') as f:
        return f.read()

setup(
    name='CriticalDifferenceDiagrams_jl',
    version='0.0.1',
    description='Python wrapper for plotting critical difference diagrams with Julia',
    long_description=readme(),
    author='Mirko Bunse',
    author_email='mirko.bunse@cs.tu-dortmund.de',
    url='https://github.com/mirkobunse/CriticalDifferenceDiagrams.jl',
    license='MIT',
    packages=find_packages(exclude=('tests', 'docs')),
    install_requires=[
        'julia_project',
        'pandas',
    ],
    include_package_data=True,
    package_data={"": ["*.jl"]},
    zip_safe=False,
    test_suite='nose.collector',
    extras_require={
        'tests': ['nose']
    },
    classifiers=[
        'Development Status :: 4 - Beta',
        'Intended Audience :: Science/Research',
        'License :: OSI Approved :: GNU General Public License v3 (GPLv3)',
        'Programming Language :: Python :: 3.10',
        'Programming Language :: Python :: 3 :: Only',
        'Topic :: Scientific/Engineering',
        'Topic :: Scientific/Engineering :: Artificial Intelligence',
        'Topic :: Scientific/Engineering :: Machine Learning'
    ],
)
