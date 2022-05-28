FROM python:3.10.4-bullseye

# install package and start unit tests
WORKDIR /CriticalDifferenceDiagrams.jl
COPY ./ ./
RUN pip install .[tests]
RUN python -c "import CriticalDifferenceDiagrams_jl"
RUN python -m unittest

CMD ["/bin/bash"]
