#
#   Auto-update manager for Jenkins puppet scripts
#
#
#   Since we're running a puppetmaster-less set up, we'll configure each node
#   to automatically update itself on a 30 minute interval


class autoupdate {
    include autoupdate::setup
    Class["autoupdate::setup"] -> Class["autoupdate"]

    cron {
        "pull puppet updates" :
            command     => "(cd /root/infra-puppet && sh run.sh)",
            user        => root,
            minute      => 30,
            ensure      => present;

        # Might as well clean these up at some point
        "clean up old puppet logs" :
            command     => "rm -f /root/puppet.*.log",
            user        => root,
            hour        => 11,
            minute      => 30,
            weekday     => 2,
            ensure      => present;
    }
}

class autoupdate::setup {
    exec {
        "setup_git_repo" :
            cwd     => "/root",
            creates => "/root/infra-puppet",
            command => "git clone git://github.com/jenkinsci/infra-puppet.git",
            require => Package["git-core"],
    }
}