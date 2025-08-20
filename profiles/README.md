Amazon AWS TOSCA Library for xOpera
===================================

This project contains a TOSCA library that can be used in xOpera for modeling
and managing AWS entities, such as VPCs, subnets, instances, etc.

## Prerequisites

To use the library, we first need a TOSCA orchestrator, such as [opera][opera].
The environment where `opera` is running from also needs the following:

* An up-to-date version of Ansible.
* The `boto3` pip library.
* The `steampunk.aws` [Ansible collection][steampunk.aws collection] from
  Ansible Galaxy.
* An account at EC2 with the AWS credentials, such as the AWS Access Key and the
  corresponding AWS Secret Key.

## Quickstart

The easiest way to start using the library is by using a Python virtual
environment.

    $ mkdir ~/ec2-deployment && cd ~/ec2-deployment
    $ python3 -m venv .venv && . .venv/bin/activate
    (.venv) $ pip install -r ~/xopera-library-aws/requirements.txt

    (.venv) $ ansible-galaxy collection install -f steampunk.aws

## Using the examples

The examples import the libraries from a subdirectory `library` that doesn't
exist in the repository. We can create the directory and a suitable symbolic
link to the directory actually containing the library:

    (.venv) $ cd examples/001-VPC-Single-Instance
    (.venv) $ mkdir library
    (.venv) $ ln -s ../../../src/steampunk library

Next, we should open the `inputs.yaml` file for editing and adjust the values as
needed.

Then, before first running the examples, we need to export the environment
variables with our client's AWS credentials:

    (.venv) $ export AWS_REGION=us-east-1                   # choose the one you prefer
    (.venv) $ export AWS_ACCESS_KEY=your-access-key         # change me
    (.venv) $ export AWS_SECRET_KEY=your-secret-access-key  # change me

The examples are now ready to run:

    (.venv) $ opera deploy --inputs inputs.yaml service.yaml


[opera]: https://github.com/xlab-si/xopera-opera
[steampunk.aws collection]: https://docs.steampunk.si/aws
