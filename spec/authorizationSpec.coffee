gh = require('../lib/authorization')

describe '_is_gh_team_admin', () ->
  beforeEach () ->
    this.auth = {
      _has_resource_role: jasmine.createSpy('_has_resource_role'),
      _is_team_admin: jasmine.createSpy('_is_team_admin'),

    }
    this.gh = gh({auth: this.auth})

  it 'returns true if the user both has the gh|user role and is a team admin', () ->
    this.auth._has_resource_role.andReturn(true)
    this.auth._is_team_admin.andReturn(true)

    cut = this.gh._is_gh_team_admin

    actual = cut('actor', 'team')

    expect(this.auth._has_resource_role).toHaveBeenCalledWith('actor', 'gh', 'user')
    expect(this.auth._is_team_admin).toHaveBeenCalledWith('actor', 'team')
    expect(actual).toBe(true)

  it 'returns false if the user does not have the gh|user role', () ->
    this.auth._has_resource_role.andReturn(false)
    this.auth._is_team_admin.andReturn(true)

    cut = this.gh._is_gh_team_admin

    actual = cut('actor', 'team')

    expect(actual).toBe(false)

  it 'returns false if the user is not a team admin', () ->
    this.auth._has_resource_role.andReturn(true)
    this.auth._is_team_admin.andReturn(false)

    cut = this.gh._is_gh_team_admin

    actual = cut('actor', 'team')

    expect(actual).toBe(false)


describe 'add_team_asset', () ->
  beforeEach () ->
    this.auth = {
      kratos:
        _is_kratos_admin: jasmine.createSpy('_is_kratos_admin'),

    }
    this.gh = gh({auth: this.auth})
    spyOn(this.gh, '_is_gh_team_admin')

  it 'allowed when user is a kratos admin', () ->

    this.auth.kratos._is_kratos_admin.andReturn(true)

    cut = this.gh.add_team_asset

    actual = cut('actor', 'team')

    expect(this.auth.kratos._is_kratos_admin).toHaveBeenCalledWith('actor')
    expect(actual).toBe(true)

  it 'allowed when user is a gh team admin and a gh user', () ->
    this.auth.kratos._is_kratos_admin.andReturn(false)
    this.gh._is_gh_team_admin.andReturn(true)
    cut = this.gh.add_team_asset

    actual = cut('actor', 'team')

    expect(this.gh._is_gh_team_admin).toHaveBeenCalledWith('actor', 'team')
    expect(actual).toBe(true)

  it 'not allowed when the user is neither a (gh team admin and gh user) nor a kratos admin', () ->
    this.auth.kratos._is_kratos_admin.andReturn(false)
    this.gh._is_gh_team_admin.andReturn(false)
    cut = this.gh.add_team_asset

    actual = cut('actor', 'team')

    expect(actual).toBe(false)

describe 'remove_team_asset', () ->
  beforeEach () ->
    this.auth = {
      kratos:
        _is_kratos_admin: jasmine.createSpy('_is_kratos_admin'),

    }
    this.gh = gh({auth: this.auth})
    spyOn(this.gh, '_is_gh_team_admin')

  it 'allowed when user is a kratos admin', () ->

    this.auth.kratos._is_kratos_admin.andReturn(true)

    cut = this.gh.remove_team_asset

    actual = cut('actor', 'team')

    expect(this.auth.kratos._is_kratos_admin).toHaveBeenCalledWith('actor')
    expect(actual).toBe(true)

  it 'allowed when user is a gh team admin and a gh user', () ->
    this.auth.kratos._is_kratos_admin.andReturn(false)
    this.gh._is_gh_team_admin.andReturn(true)

    cut = this.gh.remove_team_asset

    actual = cut('actor', 'team')

    expect(this.gh._is_gh_team_admin).toHaveBeenCalledWith('actor', 'team')
    expect(actual).toBe(true)

  it 'not allowed when the user is neither a (gh team admin and gh user) nor a kratos admin', () ->
    this.auth.kratos._is_kratos_admin.andReturn(false)
    this.gh._is_gh_team_admin.andReturn(false)

    cut = this.gh.remove_team_asset

    actual = cut('actor', 'team')

    expect(actual).toBe(false)


describe 'add_resource_role', () ->
  beforeEach () ->
    this.auth = {
      is_kratos_system_user: jasmine.createSpy('is_kratos_system_user'),
    }
    this.gh = gh({auth: this.auth})

  it 'allowed when the user is a super admin', () ->
    this.auth.is_kratos_system_user.andReturn(true)

    cut = this.gh.add_resource_role

    actual = cut('actor', 'team')

    expect(this.auth.is_kratos_system_user).toHaveBeenCalledWith('actor')
    expect(actual).toBe(true)

  it 'now allowed when the user is not a super admin', () ->
    this.auth.is_kratos_system_user.andReturn(false)

    cut = this.gh.add_resource_role

    actual = cut('actor', 'team')

    expect(this.auth.is_kratos_system_user).toHaveBeenCalledWith('actor')
    expect(actual).toBe(false)

describe 'remove_resource_role', () ->
  beforeEach () ->
    this.auth = {
      is_kratos_system_user: jasmine.createSpy('is_kratos_system_user'),
    }
    this.gh = gh({auth: this.auth})

  it 'allowed when the user is a super admin', () ->
    this.auth.is_kratos_system_user.andReturn(true)

    cut = this.gh.remove_resource_role

    actual = cut('actor', 'team')

    expect(this.auth.is_kratos_system_user).toHaveBeenCalledWith('actor')
    expect(actual).toBe(true)

  it 'now allowed when the user is not a super admin', () ->
    this.auth.is_kratos_system_user.andReturn(false)

    cut = this.gh.remove_resource_role

    actual = cut('actor', 'team')

    expect(this.auth.is_kratos_system_user).toHaveBeenCalledWith('actor')
    expect(actual).toBe(false)
