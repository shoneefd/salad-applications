import classnames from 'classnames'
import type { ReactNode } from 'react'
import { Component } from 'react'
import type { WithStyles } from 'react-jss'
import withStyles from 'react-jss'
import { P, ProgressBar, SectionHeader } from '../../../../components'
import type { SaladTheme } from '../../../../SaladTheme'
import type { Referral } from '../../../referral/models'
import { percentComplete } from '../../../referral/models'

const styles = (theme: SaladTheme) => ({
  container: {
    userSelect: 'none',
    paddingBottom: '1rem',
  },
  headerContainer: {
    display: 'flex',
    flexDirection: 'row',
    alignItems: 'flex-end',
  },
  bonusText: {
    marginLeft: 'auto',
  },
  progressBackground: {
    borderRadius: 0,
    backgroundColor: theme.darkGreen,
    height: '4px',
  },
  progressBar: {
    backgroundColor: theme.lightGreen,
    boxShadow: `0px 0px 10px 0px ${theme.lightGreen}`,
  },
})

interface Props extends WithStyles<typeof styles> {
  referral?: Referral
}

class _CurrentReferralProgress extends Component<Props> {
  public override render(): ReactNode {
    const { referral, classes } = this.props
    if (!referral || !referral.referralDefinition) return null
    return (
      <div key={referral.refereeId} className={classnames(classes.container)}>
        <SectionHeader>Your Progress</SectionHeader>

        <div className={classes.headerContainer}>
          <P>CODE: {referral.code}</P>
          <P className={classes.bonusText}>
            {percentComplete(referral) === 1
              ? 'COMPLETED'
              : `${(1 + referral.referralDefinition.bonusRate).toFixed(2)}x EARNING RATE`}
          </P>
        </div>
        <ProgressBar
          className={classes.progressBackground}
          barClassName={classes.progressBar}
          progress={percentComplete(referral) * 100}
        />
      </div>
    )
  }
}

export const CurrentReferralProgress = withStyles(styles)(_CurrentReferralProgress)
