#!/bin/bash
RULE_NAME=""
PROFILES_FILE="profiles.txt"
#AWS_ACCOUNT_NUM=$(aws sts get-caller-identity --query Account --output text --profile=dev)

if [ -f "$PROFILES_FILE" ]; then
    echo "$PROFILES_FILE exists."
else
    echo "ERROR: $(date) - Must Create $PROFILES_FILE file with profile name space region code (EX: digital-prod,us-east-1) in current path " && exit 1
fi


do_action(){
    for each_line in `cat $PROFILES_FILE`
    do
      IFS=","
      read -r -a one_line <<< "$each_line"

        if [ "enable-rule" == $1 ]; then
            aws events enable-rule --name $RULE_NAME  --profile=${one_line[0]} --region=${one_line[1]}
            echo " enable-rule ${one_line[0]}  ${one_line[1]} "

        elif [ "disable-rule" == $1 ]; then
            aws events disable-rule --name $RULE_NAME  --profile=${one_line[0]} --region=${one_line[1]}
            echo " disable-rule ${one_line[0]}  ${one_line[1]} "

        else
            aws events describe-rule --name $RULE_NAME  --profile=${one_line[0]} --region=${one_line[1]} | jq -jr '.State, "  ", .Arn'
            echo ""
        fi

    done
}


enable() {
    echo "Enable Cloud Watch Event Rule $RULE_NAME"
    do_action "enable-rule"
  #  aws events enable-rule --name $RULE_NAME  --profile=mae-co-dev
}

disable() {
    echo "Disable Cloud Watch Event Rule $RULE_NAME"
    do_action "disable-rule"
  #  aws events disable-rule --name $RULE_NAME  --profile=mae-co-dev
}

verify() {
    echo "Verify Cloud Watch Event Rule $RULE_NAME"
    do_action "describe-rule"
  #  aws events describe-rule --name $RULE_NAME  --profile=mae-co-dev | jq -jr '.State, "  ", .Arn'

}

#########################
# The command line help #
#########################
display_help() {
    echo "Usage: $0 [option...] {enable|disable|verify}" >&2
    echo
    echo "    Invalid Usage....."
    echo "    enable : option will enable the cloud watch event rule  "
    echo "    disable : option will disable the cloud watch event rule  "
    echo "    verify : option will state of the cloud watch event rule  "
    # echo some stuff here for the -a or --add-options
    exit 1
}



######################
# Match input verify #
######################
case "$1" in
  enable)
    enable # calling function enable()
    ;;
  disable)
    disable # calling function disable()
    ;;
  verify)
    verify # calling function verify()
    ;;
  *)
#    echo "Usage: $0 {enable|disable|verify}" >&2
     display_help
     exit 1
     ;;
esac
