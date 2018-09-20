package Software::Catalog::SW::bulwark::qt;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use PerlX::Maybe;

use Role::Tiny::With;
with 'Software::Catalog::Role::Software';
#with 'Software::Catalog::Role::VersionScheme::SemVer';

use Software::Catalog::Util qw(extract_from_url);

sub meta {
    return {
        homepage_url => "https://bulwarkcrypto.com/",
    };
}

sub get_latest_version {
    my ($self, %args) = @_;

    extract_from_url(
        url => "https://github.com/bulwark-crypto/Bulwark/releases",
        re  => qr!/bulwark-crypto/Bulwark/releases/download/\d+(?:\.\d+)+/bulwark-(\d+(?:\.\d+)+)-linux64\.!,
    );
}

sub canon2native_arch_map {
    return +{
        'linux-x86' => 'linux32',
        'linux-x86_64' => 'linux64',
        'win32' => 'win32',
        'win64' => 'win64',
    },
}

# version
# arch
sub get_download_url {
    my ($self, %args) = @_;

    my $version = $args{version} //
        get_latest_version(maybe arch => $args{arch});

    my $v0;
    if ($version =~ /\A(\d+\.\d+\.\d+)\.\d+\z/) {
        $v0 = $1;
    } else {
        die "Can't recognize version format $version (not x.y.z.a)";
    }

    my $ext;
    if ($args{arch} =~ /linux/) {
        $ext = ".tar.gz";
    } else {
        $ext = ".zip";
    }

    [200, "OK",
     join(
         "",
         "https://github.com/bulwark-crypto/Bulwark/releases/download/$v0/bulwark-$version-", $self->_canon2native_arch($args{arch}),
         $ext,
     ), {
         'func.unwrap_tarball' => 0,
     }];
}

sub get_programs {
    my ($self, %args) = @_;
    [200, "OK", [
        {name=>"firefox", path=>"/"},
    ]];
}

1;
# ABSTRACT: Bulwark desktop GUI client

=for Pod::Coverage ^(.+)$