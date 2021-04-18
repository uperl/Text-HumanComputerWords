use Test2::V0 -no_srand => 1;
use 5.022;
use Text::HumanComputerWords;
use experimental qw( signatures );

subtest basic => sub {

  is(
    Text::HumanComputerWords->new,
    object {
      call [ isa => 'Text::HumanComputerWords' ] => T();
      call_list [ split => 'one two https://metacpan.org mailto:plicease@cpan.org /usr/local/bin /etc c:\\foo D:/bar   three Foo::Bar::Baz YAML::XS\'s' ] => [
        [ word      => 'one'                      ],
        [ word      => 'two'                      ],
        [ url_link  => 'https://metacpan.org'     ],
        [ url_link  => 'mailto:plicease@cpan.org' ],
        [ path_name => '/usr/local/bin'           ],
        [ path_name => '/etc'                     ],
        [ path_name => 'c:\\foo'                  ],
        [ path_name => 'D:/bar'                   ],
        [ word      => 'three'                    ],
        [ module    => 'Foo::Bar::Baz'            ],
        [ module    => 'YAML::XS\'s'              ],
      ];
    },
  );

};

subtest skip => sub {

  is(
    Text::HumanComputerWords->new( skip => sub ($text) { $text eq 'foo/bar' } ),
    object {
      call [ isa => 'Text::HumanComputerWords' ] => T();
      call_list [ split => 'one two foo/bar three' ] => [
        [ word => 'one'   ],
        [ word => 'two'   ],
        [ word => 'three' ],
      ];
    },
  );

};

done_testing;
