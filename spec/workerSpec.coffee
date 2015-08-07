gh = require('../lib/worker')
Promise = require('pantheon-helpers').promise

beforeEvery = () ->
  this.api = {
    users: {
      getUser: jasmine.createSpy('getUser').andReturn(Promise.resolve('user_obj'))
    },
    teams: {
      getAllTeamRolesForUser: jasmine.createSpy('getAllTeamRolesForUser')
    }
  }
  this.validation = {
    auth: {
      _has_resource_role: jasmine.createSpy('_has_resource_role').andReturn(true)
    }
  }
  this.config = {
    RESOURCES:
      GH: {}
  }
  this.couch_utils = {
    conf: this.config
    get_system_user: jasmine.createSpy('get_system_user').andReturn('couchClient')
  }
  this.gh = gh(this.api, this.validation, this.couch_utils)
  this.git = this.gh.testing.git


describe 'add_user', () ->
  beforeEach () ->
    this.user =
      rsrcs:
        gh:
          username: 'user1'
    this.team =
      rsrcs:
        gh:
          data:
            push: 1
            admin: 2
    beforeEvery.apply(this)
    spyOn(this.git.team.user, 'add').andReturn(Promise.resolve())
    

  it 'adds a user to the github team corresponding to the users role, and resolves empty', (done) ->
    this.gh.testing.add_user(this.user, 'admin', this.team).then(() =>
      expect(this.git.team.user.add).toHaveBeenCalledWith(2, 'user1')
      done()
    ).catch(done)

  it 'adds an employee to the admin team', (done) ->
    this.user.data = {contractor: false}

    this.gh.testing.add_user(this.user, 'admin', this.team).then(() =>
      expect(this.git.team.user.add).toHaveBeenCalledWith(2, 'user1')
      done()
    ).catch(done)

  it 'adds a contractor to the push team', (done) ->
    this.user.data = {contractor: true}

    this.gh.testing.add_user(this.user, 'admin', this.team).then(() =>
      expect(this.git.team.user.add).toHaveBeenCalledWith(1, 'user1')
      done()
    ).catch(done)

  it 'does nothing if the user does not have the github|user role', (done) ->
    this.validation.auth._has_resource_role.andReturn(false)
    this.gh.testing.add_user(this.user, 'admin', this.team).then(() =>
      expect(this.git.team.user.add).not.toHaveBeenCalled();
      done()
    ).catch(done)


describe 'handle_add_user', () ->
  beforeEach beforeEvery
  it 'gets the user object and calls add_user', (done) ->
    handle_add_user = this.gh.handlers.team['u+']
    spyOn(this.gh.testing, 'add_user').andReturn(Promise.resolve('xxx'))

    handle_add_user({user: 'userid', role: 'member'}, 'team').then((resp) =>
      expect(this.api.users.getUser).toHaveBeenCalledWith('couchClient', 'userid', 'promise')
      expect(this.gh.testing.add_user).toHaveBeenCalledWith('user_obj', 'member', 'team')
      expect(resp).toBeUndefined()
      done()
    ).catch(done)

describe 'remove_user', () ->
  beforeEach () ->
    this.user =
      name: '1234'
      rsrcs:
        gh:
          username: 'user1'
    this.team =
      roles:
        admin:
          members: []
        member:
          members: []
      rsrcs:
        gh:
          data:
            push: 1
            admin: 2
    beforeEvery.apply(this)

  it 'removes a user from the github team corresponding to the users role', (done) ->
    spyOn(this.git.team.user, 'remove').andReturn(Promise.resolve())
    this.gh.testing.remove_user(this.user, 'admin', this.team).then(() =>
      expect(this.git.team.user.remove).toHaveBeenCalledWith(2, 'user1')
      done()
    ).catch(done)

  it 'removes an employee from the admin team', (done) ->
    this.user.data = {contractor: false}

    spyOn(this.git.team.user, 'remove').andReturn(Promise.resolve('xxx'))
    this.gh.testing.remove_user(this.user, 'admin', this.team).then(() =>
      expect(this.git.team.user.remove).toHaveBeenCalledWith(2, 'user1')
      done()
    ).catch(done)

  it 'removes a contractor from the push team', (done) ->
    this.user.data = {contractor: true}

    spyOn(this.git.team.user, 'remove').andReturn(Promise.resolve('xxx'))
    this.gh.testing.remove_user(this.user, 'admin', this.team).then(() =>
      expect(this.git.team.user.remove).toHaveBeenCalledWith(1, 'user1')
      done()
    ).catch(done)

  it 'removes the user even if the user does not have the github|user role', (done) ->
    this.validation.auth._has_resource_role.andReturn(false)
    spyOn(this.git.team.user, 'remove').andReturn(Promise.resolve('xxx'))
    this.gh.testing.remove_user(this.user, 'admin', this.team).then(() =>
      expect(this.git.team.user.remove).toHaveBeenCalled();
      done()
    ).catch(done)

  it 'does not remove the user if they have perms from another role in the same team', (done) ->
    this.team.roles.member.members.push('1234')
    spyOn(this.git.team.user, 'remove').andReturn(Promise.resolve('xxx'))
    this.gh.testing.remove_user(this.user, 'admin', this.team).then(() =>
      expect(this.git.team.user.remove).not.toHaveBeenCalled();
      done()
    ).catch(done)

describe 'handle_remove_user', () ->
  beforeEach beforeEvery
  it 'gets the user object and calls remove_user', (done) ->
    handle_remove_user = this.gh.handlers.team['u-']
    spyOn(this.gh.testing, 'remove_user').andReturn(Promise.resolve('xxx'))

    handle_remove_user({user: 'userid', role: 'member'}, 'team').then((resp) =>
      expect(this.api.users.getUser).toHaveBeenCalledWith('couchClient', 'userid', 'promise')
      expect(this.gh.testing.remove_user).toHaveBeenCalledWith('user_obj', 'member', 'team')
      expect(resp).toBeUndefined()
      done()
    ).catch(done)

describe 'remove_repo', () ->
  beforeEach beforeEvery
  it 'removes a repo from all github teams corresponding to a given team', (done) ->
    team =
      rsrcs:
        gh:
          data:
            push: 1
            admin: 2
    spyOn(this.git.teams.repo, 'remove').andReturn(Promise.resolve())
    this.gh.testing.remove_repo('a/b', team).then(() =>
      expect(this.git.teams.repo.remove).toHaveBeenCalledWith([1,2], 'a/b')
      done()
    ).catch(done)

describe 'handle_remove_repo', () ->
  beforeEach beforeEvery
  it 'calls remove_repo', (done) ->
    handle_remove_repo = this.gh.handlers.team.self['a-']
    spyOn(this.gh.testing, 'remove_repo').andReturn(Promise.resolve('xxx'))

    handle_remove_repo({asset: {full_name: 'reponame'}}, 'team').then((resp) =>
      expect(this.gh.testing.remove_repo).toHaveBeenCalledWith('reponame', 'team')
      expect(resp).toBeUndefined()
      done()
    ).catch(done)

describe 'add_repo', () ->
  beforeEach beforeEvery
  it 'adds a repo to all github teams corresponding to a given team', (done) ->
    team =
      rsrcs:
        gh:
          data:
            push: 1
            admin: 2
    spyOn(this.git.teams.repo, 'add').andReturn(Promise.resolve())
    this.gh.testing.add_repo('a/b', team).then(() =>
      expect(this.git.teams.repo.add).toHaveBeenCalledWith([1,2], 'a/b')
      done()
    ).catch(done)

describe 'handle_add_repo', () ->
  beforeEach beforeEvery
  it 'calls add_repo', (done) ->
    handle_add_repo = this.gh.handlers.team.self['a+']
    spyOn(this.gh.testing, 'add_repo').andReturn(Promise.resolve('xxx'))

    handle_add_repo({asset: {full_name: 'reponame'}}, 'team').then((resp) =>
      expect(this.gh.testing.add_repo).toHaveBeenCalledWith('reponame', 'team')
      expect(resp).toBeUndefined()
      done()
    ).catch(done)

describe 'create_team', () ->
  beforeEach beforeEvery
  it 'creates github admin and push teams for the created kratos team; returns a {perm: team_id} hash', (done) ->
    create_team_resp = [{
        name: 'test team admin',
        id: 1355891,
        slug: 'test-team-admin',
        description: null,
        permission: 'admin',
      },
      { 
        name: 'test team write',
        id: 1355892,
        slug: 'test-team-write',
        description: null,
        permission: 'push',
      }]

    spyOn(this.git.teams, 'create').andReturn(Promise.resolve(create_team_resp))
    this.gh.testing.create_team('test').then((resp) =>
      expect(this.git.teams.create).toHaveBeenCalledWith([{name: 'test', permission: 'admin'}, {name: 'test', permission: 'push'}])
      expect(resp).toEqual({admin: 1355891, push: 1355892})
      done()
    ).catch(done)

describe 'handle_add_gh_rsrc_role', () ->
  beforeEach beforeEvery
  it 'adds the user to every github team corresponding to a kratos to which they belong', (done) ->
    handle_add_gh_rsrc_role = this.gh.handlers.user.self['r+']
    team1 =
      rsrcs:
        gh:
          data:
            push: 11
            admin: 12
    team2 =
      rsrcs:
        gh:
          data:
            push: 21
            admin: 22
    team3 =
      rsrcs:
        gh:
          data:
            push: 31
            admin: 32
    user =
      name: '1234'
      rsrcs:
        gh:
          username: 'user1'
    spyOn(this.git.teams.user, 'add').andReturn(Promise.resolve('xxx'))
    this.api.teams.getAllTeamRolesForUser.andReturn(
      Promise.resolve([{team: team1, role: 'member'}, {team: team2, role:'member'}])
    )
    handle_add_gh_rsrc_role({}, user).then((resp) =>
      expect(this.git.teams.user.add).toHaveBeenCalledWith([12,22], 'user1')
      expect(resp).toBeUndefined()
      done()
    ).catch(done)

describe 'handle_remove_gh_rsrc_role', () ->
  beforeEach beforeEvery
  it 'removes the user from every github team corresponding to a kratos to which they belong', (done) ->
    handle_remove_gh_rsrc_role = this.gh.handlers.user.self['r-']
    team1 =
      rsrcs:
        gh:
          data:
            push: 11
            admin: 12
    team2 =
      rsrcs:
        gh:
          data:
            push: 21
            admin: 22
    team3 =
      rsrcs:
        gh:
          data:
            push: 31
            admin: 32
    user =
      name: '1234'
      rsrcs:
        gh:
          username: 'user1'
    spyOn(this.git.teams.user, 'remove').andReturn(Promise.resolve('xxx'))
    this.api.teams.getAllTeamRolesForUser.andReturn(
      Promise.resolve([{team: team1, role: 'member'}, {team: team2, role:'member'}])
    )
    handle_remove_gh_rsrc_role({}, user).then((resp) =>
      expect(this.git.teams.user.remove).toHaveBeenCalledWith([12,22], 'user1')
      expect(resp).toBeUndefined()
      done()
    ).catch(done)


describe 'handle_deactivate_user', () ->
  beforeEach () ->
    beforeEvery.apply(this)
    spyOn(this.git.user, 'delete').andReturn(Promise.resolve('xxx'))
    this.user = {rsrcs: {}}
    this.handle_deactivate_user = this.gh.handlers.user['u-']

  it 'removes the user from the org', (done) ->
    this.user.rsrcs.gh = {username: 'user1'}
    this.handle_deactivate_user({}, this.user).then((resp) =>
      expect(this.git.user.delete).toHaveBeenCalledWith('user1')
      expect(resp).toBeUndefined()
      done()
    ).catch(done)

  it 'does nothing if the user does not have a github username', (done) ->
    this.handle_deactivate_user({}, this.user).then((resp) =>
      expect(this.git.user.delete).not.toHaveBeenCalled()
      expect(resp).toBeUndefined()
      done()
    ).catch(done)

describe 'getOrCreateAsset', () ->
  beforeEach () ->
    beforeEvery.apply(this)
    spyOn(this.git.repo, 'createPush').andReturn(Promise.resolve({id: 456, name: 'test2', full_name: 'kratos-test/test2'}))
    spyOn(this.git.teams.repo, 'add').andReturn(Promise.resolve('xxx'))
    this.team =
      rsrcs:
        gh:
          assets: [
            id: "ab38f",
            gh_id: 123,
            name: "test1",
            full_name: "kratos-test/test1"
          ]
          data:
            push: 1
            admin: 2

  it 'does nothing if the repo already exists', (done) ->
    this.gh.getOrCreateAsset({new: 'test1'}, this.team).then((resp) =>
      expect(this.git.repo.createPush).not.toHaveBeenCalled()
      expect(resp).toBeUndefined()
      done()
    ).catch(done)

  it "gets/creates a repo, and returns the details to store in couch", (done) ->
    this.gh.getOrCreateAsset({new: 'test2'}, this.team).then((resp) =>
      expect(this.git.repo.createPush).toHaveBeenCalledWith({name: 'test2'})
      expect(resp).toEqual({gh_id: 456, name: 'test2', full_name: 'kratos-test/test2'})
      done()
    ).catch(done)
