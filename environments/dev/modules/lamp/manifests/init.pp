class lamp {
  class {'lamp::database': }
  class {'lamp::php': }
  class {'lamp::redis': }
  class {'lamp::nginx': }
}