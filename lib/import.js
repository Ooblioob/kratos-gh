// Generated by IcedCoffeeScript 1.8.0-e
(function() {
  var iced, parse_links, request, uuid, _, __iced_k, __iced_k_noop,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  iced = require('iced-runtime');
  __iced_k = __iced_k_noop = function() {};

  request = require('request');

  parse_links = require('parse-links');

  _ = require('underscore');

  uuid = require('node-uuid');

  module.exports = function(couch_utils) {
    var conf, get_all, gh_conf, gha, gha_url, import_members, import_repos, import_team, x;
    conf = couch_utils.conf;
    gh_conf = conf.RESOURCES.GH;
    gha_url = 'https://api.github.com';
    gha = request.defaults({
      auth: gh_conf.ADMIN_CREDENTIALS,
      json: true,
      headers: {
        'User-Agent': 'cfpb-kratos'
      }
    });
    get_all = function(client, url, callback) {
      var data, err, link_header, links, out, resp, ___iced_passed_deferral, __iced_deferrals, __iced_k;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      out = [];
      (function(_this) {
        return (function(__iced_k) {
          var _results, _while;
          _results = [];
          _while = function(__iced_k) {
            var _break, _continue, _next;
            _break = function() {
              return __iced_k(_results);
            };
            _continue = function() {
              return iced.trampoline(function() {
                return _while(__iced_k);
              });
            };
            _next = function(__iced_next_arg) {
              _results.push(__iced_next_arg);
              return _continue();
            };
            if (!url) {
              return _break();
            } else {
              (function(__iced_k) {
                __iced_deferrals = new iced.Deferrals(__iced_k, {
                  parent: ___iced_passed_deferral,
                  filename: "/Users/greisend/programming/devdash/pantheon-repos/kratos/node_modules/kratos-gh/src/import.iced"
                });
                client.get(url, __iced_deferrals.defer({
                  assign_fn: (function() {
                    return function() {
                      err = arguments[0];
                      resp = arguments[1];
                      return data = arguments[2];
                    };
                  })(),
                  lineno: 18
                }));
                __iced_deferrals._fulfill();
              })(function() {
                if (err) {
                  return err;
                }
                out = out.concat(data);
                link_header = resp.headers.link;
                if (link_header != null) {
                  links = parse_links(link_header);
                }
                return _next(url = (links != null ? links.next : void 0) || null);
              });
            }
          };
          _while(__iced_k);
        });
      })(this)((function(_this) {
        return function() {
          return callback(null, out);
        };
      })(this));
    };
    x = {};
    x.import_users = function(callback) {
      var db, err, i, member, members, url, users, uuids, ___iced_passed_deferral, __iced_deferrals, __iced_k;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      url = gha_url + '/organizations/' + gh_conf.ORG_ID + '/members';
      (function(_this) {
        return (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "/Users/greisend/programming/devdash/pantheon-repos/kratos/node_modules/kratos-gh/src/import.iced",
            funcname: "import_users"
          });
          get_all(gha, url, __iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                err = arguments[0];
                return members = arguments[1];
              };
            })(),
            lineno: 30
          }));
          __iced_deferrals._fulfill();
        });
      })(this)((function(_this) {
        return function() {
          users = [];
          (function(__iced_k) {
            __iced_deferrals = new iced.Deferrals(__iced_k, {
              parent: ___iced_passed_deferral,
              filename: "/Users/greisend/programming/devdash/pantheon-repos/kratos/node_modules/kratos-gh/src/import.iced",
              funcname: "import_users"
            });
            couch_utils.get_uuids(members.length, __iced_deferrals.defer({
              assign_fn: (function() {
                return function() {
                  err = arguments[0];
                  return uuids = arguments[1];
                };
              })(),
              lineno: 32
            }));
            __iced_deferrals._fulfill();
          })(function() {
            var _i, _len;
            for (i = _i = 0, _len = members.length; _i < _len; i = ++_i) {
              member = members[i];
              users.push({
                _id: "org.couchdb.user:" + uuids[i],
                type: "user",
                name: uuids[i],
                roles: ["kratos|enabled"],
                data: {
                  username: member.login
                },
                password: conf.COUCH_PWD,
                rsrcs: {
                  gh: {
                    username: member.login,
                    id: member.id
                  }
                },
                audit: []
              });
            }
            db = couch_utils.nano_system_user.use('_users');
            return db.bulk({
              docs: users
            }, callback);
          });
        };
      })(this));
    };
    x.importTeams = function(db_name, admin_id, callback) {
      var db, err, errs, i, name, perm, raw_team, raw_teams, resp, start_time, team, team_data, team_docs, team_name, teams, typ, url, ___iced_passed_deferral, __iced_deferrals, __iced_k;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      start_time = +new Date();
      url = gha_url + '/organizations/' + gh_conf.ORG_ID + '/teams';
      (function(_this) {
        return (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "/Users/greisend/programming/devdash/pantheon-repos/kratos/node_modules/kratos-gh/src/import.iced",
            funcname: "importTeams"
          });
          get_all(gha, url, __iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                err = arguments[0];
                return raw_teams = arguments[1];
              };
            })(),
            lineno: 58
          }));
          __iced_deferrals._fulfill();
        });
      })(this)((function(_this) {
        return function() {
          var _i, _len, _ref, _ref1;
          if (err) {
            callback(err);
          }
          teams = {};
          for (_i = 0, _len = raw_teams.length; _i < _len; _i++) {
            raw_team = raw_teams[_i];
            if (_ref = raw_team.id, __indexOf.call(gh_conf.UNMANAGED_TEAMS, _ref) >= 0) {
              continue;
            }
            _ref1 = raw_team.name.split(' '), name = _ref1[0], typ = _ref1[1], perm = _ref1[2];
            raw_team.perm = perm;
            raw_team.iname = name;
            if (typ !== 'team') {
              continue;
            }
            if (teams[name] == null) {
              teams[name] = {};
            }
            teams[name][perm] = raw_team;
          }
          team_data = [];
          errs = [];
          (function(__iced_k) {
            __iced_deferrals = new iced.Deferrals(__iced_k, {
              parent: ___iced_passed_deferral,
              filename: "/Users/greisend/programming/devdash/pantheon-repos/kratos/node_modules/kratos-gh/src/import.iced",
              funcname: "importTeams"
            });
            i = 0;
            for (team_name in teams) {
              team = teams[team_name];
              import_team(team, admin_id, __iced_deferrals.defer({
                assign_fn: (function(__slot_1, __slot_2, __slot_3, __slot_4) {
                  return function() {
                    __slot_1[__slot_2] = arguments[0];
                    return __slot_3[__slot_4] = arguments[1];
                  };
                })(errs, i, team_data, i),
                lineno: 77
              }));
              i++;
            }
            __iced_deferrals._fulfill();
          })(function() {
            errs = _.compact(errs);
            if (errs.length) {
              return callback(errs);
            }
            team_docs = {
              docs: team_data
            };
            db = couch_utils.nano_system_user.use('org_' + db_name);
            (function(__iced_k) {
              __iced_deferrals = new iced.Deferrals(__iced_k, {
                parent: ___iced_passed_deferral,
                filename: "/Users/greisend/programming/devdash/pantheon-repos/kratos/node_modules/kratos-gh/src/import.iced",
                funcname: "importTeams"
              });
              couch_utils.ensure_db(db, 'bulk', team_docs, __iced_deferrals.defer({
                assign_fn: (function() {
                  return function() {
                    err = arguments[0];
                    return resp = arguments[1];
                  };
                })(),
                lineno: 83
              }));
              __iced_deferrals._fulfill();
            })(function() {
              if (err) {
                return callback(err);
              }
              console.log('total time:', +new Date() - start_time);
              return callback();
            });
          });
        };
      })(this));
    };
    import_team = function(teams, admin_id, callback) {
      var i, member_errs, now, record, repo_errs, role_doc, rsrc_doc, team_doc, ___iced_passed_deferral, __iced_deferrals, __iced_k;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      now = +new Date();
      (function(_this) {
        return (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "/Users/greisend/programming/devdash/pantheon-repos/kratos/node_modules/kratos-gh/src/import.iced"
          });
          import_repos(teams, admin_id, __iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                repo_errs = arguments[0];
                return rsrc_doc = arguments[1];
              };
            })(),
            lineno: 91
          }));
          i = 0;
          import_members(teams, admin_id, __iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                member_errs = arguments[0];
                return role_doc = arguments[1];
              };
            })(),
            lineno: 93
          }));
          __iced_deferrals._fulfill();
        });
      })(this)((function(_this) {
        return function() {
          if (repo_errs || member_errs) {
            return callback([repo_errs, member_errs]);
          }
          team_doc = {
            _id: 'team_' + teams['admin'].iname,
            name: teams['admin'].iname,
            rsrcs: {
              'gh': rsrc_doc
            },
            roles: role_doc,
            audit: [
              {
                u: admin_id,
                dt: now,
                a: 't+',
                id: uuid.v4()
              }
            ],
            enforce: []
          };
          record = _.clone(team_doc);
          delete record.enforce;
          delete record.audit;
          record.rsrcs = _.clone(record.rsrcs);
          record.rsrcs.gh = _.clone(record.rsrcs.gh);
          delete record.rsrcs.gh.data;
          team_doc.audit[0].r = record;
          return callback(null, team_doc);
        };
      })(this));
    };
    import_members = function(teams, admin_id, callback) {
      var err, i, member_gh_ids, members, role_doc, team, team_name, url, user, user_rows, ___iced_passed_deferral, __iced_deferrals, __iced_k;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      role_doc = {
        member: {
          members: []
        }
      };
      members = [];
      err = [];
      (function(_this) {
        return (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "/Users/greisend/programming/devdash/pantheon-repos/kratos/node_modules/kratos-gh/src/import.iced"
          });
          i = 0;
          for (team_name in teams) {
            team = teams[team_name];
            url = team.url + '/members';
            get_all(gha, url, __iced_deferrals.defer({
              assign_fn: (function(__slot_1, __slot_2, __slot_3, __slot_4) {
                return function() {
                  __slot_1[__slot_2] = arguments[0];
                  return __slot_3[__slot_4] = arguments[1];
                };
              })(err, i, members, i),
              lineno: 128
            }));
            i++;
          }
          __iced_deferrals._fulfill();
        });
      })(this)((function(_this) {
        return function() {
          err = _.compact(err);
          if (err.length) {
            return callback(err);
          }
          members = _.flatten(members, true);
          members = _.map(members, function(item) {
            return item.id;
          });
          members = _.uniq(members);
          member_gh_ids = _.map(members, function(item) {
            return ['gh', item];
          });
          (function(__iced_k) {
            __iced_deferrals = new iced.Deferrals(__iced_k, {
              parent: ___iced_passed_deferral,
              filename: "/Users/greisend/programming/devdash/pantheon-repos/kratos/node_modules/kratos-gh/src/import.iced"
            });
            couch_utils.nano_system_user.use('_users').view('base', 'by_resource_id', {
              keys: member_gh_ids
            }, __iced_deferrals.defer({
              assign_fn: (function() {
                return function() {
                  err = arguments[0];
                  return user_rows = arguments[1];
                };
              })(),
              lineno: 137
            }));
            __iced_deferrals._fulfill();
          })(function() {
            var _i, _len, _ref;
            if (err) {
              return callback(err);
            }
            _ref = user_rows.rows;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              user = _ref[_i];
              role_doc.member.members.push(user.value);
            }
            return callback(null, role_doc);
          });
        };
      })(this));
    };
    import_repos = function(teams, admin_id, callback) {
      var err, repo, repo_record, repos, resource_doc, team, url, ___iced_passed_deferral, __iced_deferrals, __iced_k;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      team = teams['admin'];
      resource_doc = {
        assets: [],
        data: _.object(_.map(teams, function(item) {
          return [item.perm, item.id];
        }))
      };
      url = team.url + '/repos';
      (function(_this) {
        return (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "/Users/greisend/programming/devdash/pantheon-repos/kratos/node_modules/kratos-gh/src/import.iced"
          });
          get_all(gha, url, __iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                err = arguments[0];
                return repos = arguments[1];
              };
            })(),
            lineno: 152
          }));
          __iced_deferrals._fulfill();
        });
      })(this)((function(_this) {
        return function() {
          var _i, _len;
          if (err) {
            return callback(err);
          }
          for (_i = 0, _len = repos.length; _i < _len; _i++) {
            repo = repos[_i];
            repo_record = {
              id: uuid.v4(),
              gh_id: repo.id,
              name: repo.name,
              full_name: repo.full_name
            };
            resource_doc.assets.push(repo_record);
          }
          return callback(null, resource_doc);
        };
      })(this));
    };
    x.importAll = function(db_name, callback) {
      var admin_id, err, resp, ___iced_passed_deferral, __iced_deferrals, __iced_k;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      admin_id = 'admin';
      (function(_this) {
        return (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "/Users/greisend/programming/devdash/pantheon-repos/kratos/node_modules/kratos-gh/src/import.iced",
            funcname: "importAll"
          });
          x.import_users(__iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                err = arguments[0];
                return resp = arguments[1];
              };
            })(),
            lineno: 162
          }));
          __iced_deferrals._fulfill();
        });
      })(this)((function(_this) {
        return function() {
          if (err) {
            return callback(err);
          }
          (function(__iced_k) {
            __iced_deferrals = new iced.Deferrals(__iced_k, {
              parent: ___iced_passed_deferral,
              filename: "/Users/greisend/programming/devdash/pantheon-repos/kratos/node_modules/kratos-gh/src/import.iced",
              funcname: "importAll"
            });
            x.importTeams(db_name, admin_id, __iced_deferrals.defer({
              assign_fn: (function() {
                return function() {
                  err = arguments[0];
                  return resp = arguments[1];
                };
              })(),
              lineno: 164
            }));
            __iced_deferrals._fulfill();
          })(function() {
            if (err) {
              callback(err);
            }
            return callback();
          });
        };
      })(this));
    };
    return x;
  };

}).call(this);