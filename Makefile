.PHONY: clean run
RUN := runs/run_$(shell date +%F-%H-%M-%S)

JOB=jobs/meerkat16_deep2_sphe.yaml

all: run

clean:
	rm -rf .virtualenv

.virtualenv/:
	virtualenv -p python2 .virtualenv
 
.virtualenv-system/:
	virtualenv --system-site-packages -p python2 .virtualenv-system
	.virtualenv-system/bin/pip install -r requirements.txt
 
.virtualenv/bin/cwltool: .virtualenv/
	.virtualenv/bin/pip install -r requirements.txt

.virtualenv/bin/cwltoil: .virtualenv/
	.virtualenv/bin/pip install -r requirements.txt

docker:
	docker build -t gijzelaerr/spiel .

run: .virtualenv/bin/cwltool docker
	.virtualenv/bin/cwltool \
		--tmpdir `pwd`/tmp/ \
		--cachedir `pwd`/cache/ \
		--outdir `pwd`/results/ \
		spiel.cwl \
		${JOB}

multi: .virtualenv/bin/cwltoil docker
	mkdir -p $(RUN)/results
	.virtualenv/bin/toil-cwl-runner \
		--stats \
	    --cleanWorkDir onSuccess \
		--logFile $(RUN)/log \
		--outdir $(RUN)/results \
		--jobStore file:///$(CURDIR)/$(RUN)/job_store \
		--workDir $(CURDIR)/work \
		multi.cwl \
		${JOB}

mesos: .virtualenv-system/bin/cwltoil docker
	mkdir -p $(RUN)/results
	.virtualenv/bin/toil-cwl-runner \
		--batchSystem mesos \
		--mesosMaster stem6.sdp.kat.ac.za:5050 \
		multi.cwl \
		${JOB}

slurm: .virtualenv/bin/cwltoil
	mkdir -p $(RUN)/results
	.virtualenv/bin/toil-cwl-runner \
	--batchSystem slurm \
	--singularity \
	--cleanWorkDir onSuccess \
	--logFile $(RUN)/log \
	--outdir $(RUN)/results \
	--jobStore file:///$(CURDIR)/$(RUN)/job_store \
	--workDir $(CURDIR)/work \
	multi.cwl \
	${JOB}


srun: .virtualenv/bin/cwltool
	.virtualenv/bin/cwltool \
		--debug \
        --singularity \
		--tmpdir `pwd`/tmp/ \
		--cachedir `pwd`/cache/ \
		--outdir `pwd`/results/ \
		spiel.cwl \
		${JOB}

smulti: .virtualenv/bin/cwltoil
	mkdir -p $(RUN)/results
	.virtualenv/bin/toil-cwl-runner \
		--stats \
        --singularity \
	    --cleanWorkDir onSuccess \
		--logFile $(RUN)/log \
		--outdir $(RUN)/results \
		--jobStore file:///$(CURDIR)/$(RUN)/job_store \
		--workDir $(CURDIR)/work \
		multi.cwl \
		${JOB}
