/******************************************************************************
 * Top contributors (to current version):
 *   Andrew Reynolds, Aina Niemetz
 *
 * This file is part of the cvc5 project.
 *
 * Copyright (c) 2009-2021 by the authors listed in the file AUTHORS
 * in the top-level source directory and their institutional affiliations.
 * All rights reserved.  See the file COPYING in the top-level source
 * directory for licensing information.
 * ****************************************************************************
 *
 * Module for managing options of an SmtEngine.
 */

#include "smt/options_manager.h"

#include "base/output.h"
#include "expr/expr_iomanip.h"
#include "options/base_options.h"
#include "options/expr_options.h"
#include "options/smt_options.h"
#include "smt/command.h"
#include "smt/dump.h"
#include "smt/set_defaults.h"
#include "util/resource_manager.h"

namespace cvc5 {
namespace smt {

OptionsManager::OptionsManager(Options* opts) : d_options(opts)
{
  // set options that must take effect immediately
  if (opts->wasSetByUser(options::defaultExprDepth))
  {
    notifySetOption(options::defaultExprDepth.name);
  }
  if (opts->wasSetByUser(options::defaultDagThresh))
  {
    notifySetOption(options::defaultDagThresh.name);
  }
  if (opts->wasSetByUser(options::dumpModeString))
  {
    notifySetOption(options::dumpModeString.name);
  }
  if (opts->wasSetByUser(options::printSuccess))
  {
    notifySetOption(options::printSuccess.name);
  }
  if (opts->wasSetByUser(options::diagnosticChannelName))
  {
    notifySetOption(options::diagnosticChannelName.name);
  }
  if (opts->wasSetByUser(options::regularChannelName))
  {
    notifySetOption(options::regularChannelName.name);
  }
  if (opts->wasSetByUser(options::dumpToFileName))
  {
    notifySetOption(options::dumpToFileName.name);
  }
  // set this as a listener to be notified of options changes from now on
  opts->setListener(this);
}

OptionsManager::~OptionsManager() {}

void OptionsManager::notifySetOption(const std::string& key)
{
  Trace("smt") << "SmtEnginePrivate::notifySetOption(" << key << ")"
               << std::endl;
  if (key == options::defaultExprDepth.name)
  {
    int depth = (*d_options)[options::defaultExprDepth];
    Debug.getStream() << expr::ExprSetDepth(depth);
    Trace.getStream() << expr::ExprSetDepth(depth);
    Notice.getStream() << expr::ExprSetDepth(depth);
    Chat.getStream() << expr::ExprSetDepth(depth);
    CVC5Message.getStream() << expr::ExprSetDepth(depth);
    Warning.getStream() << expr::ExprSetDepth(depth);
    // intentionally exclude Dump stream from this list
  }
  else if (key == options::defaultDagThresh.name)
  {
    int dag = (*d_options)[options::defaultDagThresh];
    Debug.getStream() << expr::ExprDag(dag);
    Trace.getStream() << expr::ExprDag(dag);
    Notice.getStream() << expr::ExprDag(dag);
    Chat.getStream() << expr::ExprDag(dag);
    CVC5Message.getStream() << expr::ExprDag(dag);
    Warning.getStream() << expr::ExprDag(dag);
    Dump.getStream() << expr::ExprDag(dag);
  }
  else if (key == options::dumpModeString.name)
  {
    const std::string& value = (*d_options)[options::dumpModeString];
    Dump.setDumpFromString(value);
  }
  else if (key == options::printSuccess.name)
  {
    bool value = (*d_options)[options::printSuccess];
    Debug.getStream() << Command::printsuccess(value);
    Trace.getStream() << Command::printsuccess(value);
    Notice.getStream() << Command::printsuccess(value);
    Chat.getStream() << Command::printsuccess(value);
    CVC5Message.getStream() << Command::printsuccess(value);
    Warning.getStream() << Command::printsuccess(value);
    *options::out() << Command::printsuccess(value);
  }
  else if (key == options::regularChannelName.name)
  {
    d_managedRegularChannel.set(options::regularChannelName());
  }
  else if (key == options::diagnosticChannelName.name)
  {
    d_managedDiagnosticChannel.set(options::diagnosticChannelName());
  }
  else if (key == options::dumpToFileName.name)
  {
    d_managedDumpChannel.set(options::dumpToFileName());
  }
  // otherwise, no action is necessary
}

void OptionsManager::finishInit(LogicInfo& logic, bool isInternalSubsolver)
{
  // ensure that our heuristics are properly set up
  setDefaults(logic, isInternalSubsolver);
}

}  // namespace smt
}  // namespace cvc5
