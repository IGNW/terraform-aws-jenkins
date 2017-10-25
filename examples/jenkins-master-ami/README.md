# Jenkins Master AMI

This folder shows an example Jenkins master server build using a packer template to generate an AMI.
 
OS: _Amazon Linux_

These AMIs will have [Jenkins](https://www.jenkins.io/) installed and configured to automatically run the Jenkins daemon service. You would need to tailor this environment 
to include your build tools or run all builds on slave instance(s).

Installed
* Java 1.8 Open JDK
* Git Tools
* AWS CLI Tools
* Apache Maven
* Jenkins

## Quick start

To build the Jenkins Master AMI:

1. `git clone` this repo to your computer.
1. Install [Packer](https://www.packer.io/).
1. Configure your AWS credentials using one of the [options supported by the AWS 
   SDK](http://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/credentials.html). Usually, the easiest option is to
   set the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables.
1. Update the `variables` section of the `jenkins.json` Packer template to configure the AWS region and Jenkins version you wish to use.
1. Run `packer build jenkins.json`.

When the build finishes, it will output the IDs of the new AMIs. To see how to deploy one of these AMIs, check out the 
[jenkins example](https://github.com/ignw/terraform-aws-jenkins/tree/master/MAIN.md).