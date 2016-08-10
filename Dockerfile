FROM debian:stable
MAINTAINER Richard Ulrich   "richi@ulrichard.ch"

# install instructions for sky can be found here: https://tel.red/repos.htm

# Tell debconf to run in non-interactive mode
ENV DEBIAN_FRONTEND noninteractive

# Setup multiarch because Skype is 32bit only
#RUN dpkg --add-architecture i386

# Make sure the repository information is up to date
RUN apt-get update

# Ensure APT works with HTTPS and up-to-date CA certificates are installed
RUN apt-get install -y apt-transport-https ca-certificates

# Add appropriate TEL.RED repository to APT sources list
RUN sh -c 'echo deb https://tel.red/repos/debian jessie non-free > /etc/apt/sources.list.d/telred.list'

# Download and register TEL.RED software signing public key:
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 9454C19A66B920C83DDF696E07C8CCAFCE49F8C5

# Make sure the repository information is up to date
RUN apt-get update

# Install PulseAudio for i386 (64bit version does not work with Skype)
#RUN apt-get install -y libpulse0:i386 pulseaudio:i386

# We need ssh to access the docker container, wget to download skype
RUN apt-get install -y openssh-server wget sky

# Create user "docker" and set the password to "docker"
RUN useradd -m -d /home/docker docker
RUN echo "docker:docker" | chpasswd

# Create OpenSSH privilege separation directory, enable X11Forwarding
RUN mkdir -p /var/run/sshd
RUN echo X11Forwarding yes >> /etc/ssh/ssh_config

# Prepare ssh config folder so we can upload SSH public key later
RUN mkdir /home/docker/.ssh
RUN chown -R docker:docker /home/docker
RUN chown -R docker:docker /home/docker/.ssh

# Set locale (fix locale warnings)
RUN localedef -v -c -i en_US -f UTF-8 en_US.UTF-8 || true
RUN echo "Europe/Prague" > /etc/timezone

# Set up the launch wrapper - sets up PulseAudio to work correctly
#RUN echo 'export PULSE_SERVER="tcp:localhost:64713"' >> /usr/local/bin/skype-pulseaudio
#RUN echo 'PULSE_LATENCY_MSEC=60 skype' >> /usr/local/bin/skype-pulseaudio
#RUN chmod 755 /usr/local/bin/skype-pulseaudio


# Expose the SSH port
EXPOSE 22

# Start SSH
ENTRYPOINT ["/usr/sbin/sshd",  "-D"]
