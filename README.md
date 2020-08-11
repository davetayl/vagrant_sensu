# vagrant_sensu
## Purpose
This PoC is intended to provide a plaform for testing Sensu, as such the following functions/components will be installed:-
* Sensue Backend
    * Sensue Backend - Used as the server componets of Sensu, providing modelling, metric collection etc
    * InfluxDB - Used for storage or time series data related to checks run on using sensu agents
    * Grafana - used for visualisation of data stored in InfluxDB
* Sensu agents
    * Sensu agent - sensu remote polling element 
    * Ping and trace check - basic python module to check latency to the sensu server and up to 5 hops of traceroute

* Future
    * Voice quality check - python module that checks chall quality based on SIP and RTP response
    * Configuration interface - needs to be reviewed maybe use API key only or more detailed config.

## Implementation
* CentOS8 as the OS due to newer packages and ongoning supportability
* One VM per major service to mirror provide
* Single internal LAN
* Initially with Selinux set to permissive, once all other functional testing is complete the final phase MUST include hardening

## Security Information
Final deployment MUST follow internal requirements, however where internal requirements are not available the following sources may be used to assist in securing the system to an accesptable degree. The final PoC MUST include hardening and security appropriate for production workloads, however where unabavailble external systems are required this may be skipped provided it is noted as a caveat of the PoC and due dilligence has been done to indicate the addition will not cause a functional issue.
* [Redhat RHEL 8.x Hardening guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html-single/security_hardening/index#scanning-the-system-for-security-compliance-and-vulnerabilities_security-hardening)
* [NIST Hardening guide for RHEL 8.x](https://nvd.nist.gov/ncp/checklist/revision/3782)
* [OSCAP Hardening guide for RHEL 8.x](http://static.open-scap.org/ssg-guides/ssg-rhel8-guide-cui.html)
* [Sensu Guide - Securing Sensu](https://docs.sensu.io/sensu-core/1.1/guides/securing-sensu/)
